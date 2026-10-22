import 'dart:typed_data';

/// Result of document validation
class DocumentValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sanitizedPath;

  const DocumentValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.sanitizedPath,
  });

  factory DocumentValidationResult.success(String sanitizedPath) =>
      DocumentValidationResult._(isValid: true, sanitizedPath: sanitizedPath);

  factory DocumentValidationResult.failure(String errorMessage) =>
      DocumentValidationResult._(isValid: false, errorMessage: errorMessage);
}

/// Service enforcing institutional storage security policies:
/// - Target private buckets ('documents', 'receipts', 'transcripts')
/// - Validate allowed MIME types (PDF, JPEG, PNG)
/// - Validate file size (max 5MB for receipts, 10MB for documents)
/// - Enforce user folder isolation and ownership
class SecureDocumentService {
  static const Set<String> allowedMimeTypes = {
    'application/pdf',
    'image/jpeg',
    'image/png',
  };

  static const Set<String> allowedExtensions = {
    'pdf',
    'jpg',
    'jpeg',
    'png',
  };

  static const int maxReceiptSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxDocumentSizeBytes = 10 * 1024 * 1024; // 10 MB

  /// Validates document upload payload before sending to Supabase private storage
  static DocumentValidationResult validateUpload({
    required String bucket,
    required String fileName,
    required String mimeType,
    required int fileSizeBytes,
    required String authenticatedUserId,
  }) {
    // 1. Bucket isolation: Only allow private buckets
    final allowedBuckets = {'documents', 'receipts', 'transcripts'};
    if (!allowedBuckets.contains(bucket)) {
      return DocumentValidationResult.failure(
        'Upload rejected: Target bucket "$bucket" is not an authorized private bucket.',
      );
    }

    // 2. MIME type verification
    final normalizedMime = mimeType.toLowerCase().trim();
    if (!allowedMimeTypes.contains(normalizedMime)) {
      return DocumentValidationResult.failure(
        'Upload rejected: Unsupported file format "$mimeType". Only PDF, JPEG, and PNG files are accepted.',
      );
    }

    // 3. Extension verification
    final extension = fileName.split('.').last.toLowerCase().trim();
    if (!allowedExtensions.contains(extension)) {
      return DocumentValidationResult.failure(
        'Upload rejected: Invalid file extension ".$extension".',
      );
    }

    // 4. File size limitation
    final maxAllowedSize = bucket == 'receipts' ? maxReceiptSizeBytes : maxDocumentSizeBytes;
    if (fileSizeBytes > maxAllowedSize) {
      final maxMb = (maxAllowedSize / (1024 * 1024)).toStringAsFixed(0);
      return DocumentValidationResult.failure(
        'Upload rejected: File size exceeds the maximum permitted limit of $maxMb MB.',
      );
    }

    if (fileSizeBytes <= 0) {
      return DocumentValidationResult.failure('Upload rejected: File is empty.');
    }

    // 5. Ownership path isolation (auth.uid() folder enforcement)
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_\.-]'), '_');
    final sanitizedStoragePath = '$authenticatedUserId/$cleanFileName';

    return DocumentValidationResult.success(sanitizedStoragePath);
  }

  /// Validates raw byte headers (Magic bytes) to detect forged extensions
  static bool hasValidMagicBytes(Uint8List bytes, String extension) {
    if (bytes.length < 4) return false;

    final ext = extension.toLowerCase();
    if (ext == 'pdf') {
      // PDF magic bytes: %PDF (0x25, 0x50, 0x44, 0x46)
      return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46;
    } else if (ext == 'jpg' || ext == 'jpeg') {
      // JPEG magic bytes: 0xFF, 0xD8, 0xFF
      return bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    } else if (ext == 'png') {
      // PNG magic bytes: 0x89, 0x50, 0x4E, 0x47
      return bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
    }

    return false;
  }
}
