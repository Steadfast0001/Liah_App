import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/services/secure_document_service.dart';
import 'package:liah_app/services/security_audit_service.dart';

void main() {
  group('Liah Academy — Security Requirements Test Suite', () {
    test('Zero service-role keys are exposed in client-side Flutter code', () {
      final libDir = Directory('lib');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        expect(
          content.contains('service_role'),
          isFalse,
          reason: 'Forbidden service-role key reference found in ${file.path}',
        );
        expect(
          content.contains('SUPABASE_SERVICE_ROLE_KEY'),
          isFalse,
          reason: 'Forbidden service key environment found in ${file.path}',
        );
      }
    });

    test('SecureDocumentService permits valid PDF, JPEG, and PNG in private buckets', () {
      final validPdf = SecureDocumentService.validateUpload(
        bucket: 'documents',
        fileName: 'admission_letter.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024 * 500, // 500 KB
        authenticatedUserId: 'user-uuid-1234',
      );
      expect(validPdf.isValid, isTrue);
      expect(validPdf.sanitizedPath, 'user-uuid-1234/admission_letter.pdf');

      final validReceipt = SecureDocumentService.validateUpload(
        bucket: 'receipts',
        fileName: 'bank_slip.jpg',
        mimeType: 'image/jpeg',
        fileSizeBytes: 1024 * 300, // 300 KB
        authenticatedUserId: 'user-uuid-1234',
      );
      expect(validReceipt.isValid, isTrue);
      expect(validReceipt.sanitizedPath, 'user-uuid-1234/bank_slip.jpg');
    });

    test('SecureDocumentService rejects unauthorized buckets', () {
      final result = SecureDocumentService.validateUpload(
        bucket: 'public-files',
        fileName: 'doc.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024,
        authenticatedUserId: 'user-uuid-1234',
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('not an authorized private bucket'));
    });

    test('SecureDocumentService rejects disallowed MIME types and malicious extensions', () {
      final badMime = SecureDocumentService.validateUpload(
        bucket: 'documents',
        fileName: 'exploit.exe',
        mimeType: 'application/x-msdownload',
        fileSizeBytes: 1024,
        authenticatedUserId: 'user-uuid-1234',
      );
      expect(badMime.isValid, isFalse);
      expect(badMime.errorMessage, contains('Unsupported file format'));

      final badExt = SecureDocumentService.validateUpload(
        bucket: 'documents',
        fileName: 'script.php',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024,
        authenticatedUserId: 'user-uuid-1234',
      );
      expect(badExt.isValid, isFalse);
      expect(badExt.errorMessage, contains('Invalid file extension'));
    });

    test('SecureDocumentService enforces max file size boundaries', () {
      // Receipts max is 5MB
      final oversizedReceipt = SecureDocumentService.validateUpload(
        bucket: 'receipts',
        fileName: 'large_slip.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 6 * 1024 * 1024, // 6 MB
        authenticatedUserId: 'user-uuid-1234',
      );
      expect(oversizedReceipt.isValid, isFalse);
      expect(oversizedReceipt.errorMessage, contains('exceeds the maximum permitted limit of 5 MB'));

      // Empty file rejected
      final emptyFile = SecureDocumentService.validateUpload(
        bucket: 'documents',
        fileName: 'empty.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 0,
        authenticatedUserId: 'user-uuid-1234',
      );
      expect(emptyFile.isValid, isFalse);
      expect(emptyFile.errorMessage, contains('File is empty'));
    });

    test('SecureDocumentService detects valid and invalid magic bytes', () {
      // PDF: %PDF
      final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31]);
      expect(SecureDocumentService.hasValidMagicBytes(pdfBytes, 'pdf'), isTrue);

      // JPEG: 0xFF, 0xD8, 0xFF
      final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
      expect(SecureDocumentService.hasValidMagicBytes(jpegBytes, 'jpg'), isTrue);

      // PNG: 0x89, 0x50, 0x4E, 0x47
      final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]);
      expect(SecureDocumentService.hasValidMagicBytes(pngBytes, 'png'), isTrue);

      // Forged PDF with executable bytes (e.g. MZ)
      final forgedBytes = Uint8List.fromList([0x4D, 0x5A, 0x90, 0x00]);
      expect(SecureDocumentService.hasValidMagicBytes(forgedBytes, 'pdf'), isFalse);
    });

    test('SecurityAuditService scrubs passwords, tokens, and payment credentials', () {
      final sensitiveData = {
        'userId': 'usr_99182',
        'matricule': 'LIAH-2024-SW0482',
        'password': 'SuperSecretPassword123!',
        'new_password': 'AnotherPassword!',
        'access_token': 'eyJh...token...payload',
        'card_number': '4111111111111111',
        'cvv': '789',
        'pin': '1234',
        'amountXaf': 250000,
        'nested': {
          'api_key': 'key_live_abcdef',
          'status': 'verified',
        },
      };

      final scrubbed = SecurityAuditService.scrubPayload(sensitiveData);

      expect(scrubbed['userId'], 'usr_99182');
      expect(scrubbed['matricule'], 'LIAH-2024-SW0482');
      expect(scrubbed['amountXaf'], 250000);
      expect(scrubbed['password'], '[REDACTED]');
      expect(scrubbed['new_password'], '[REDACTED]');
      expect(scrubbed['access_token'], '[REDACTED]');
      expect(scrubbed['card_number'], '[REDACTED]');
      expect(scrubbed['cvv'], '[REDACTED]');
      expect(scrubbed['pin'], '[REDACTED]');
      expect(scrubbed['nested']['api_key'], '[REDACTED]');
      expect(scrubbed['nested']['status'], 'verified');
    });

    test('SecurityAuditService verifies MFA / AAL2 session claims', () {
      expect(SecurityAuditService.isPrivilegedSessionAal2(null), isFalse);
      expect(SecurityAuditService.isPrivilegedSessionAal2({'aal': 'aal1'}), isFalse);
      expect(SecurityAuditService.isPrivilegedSessionAal2({'aal': 'aal2'}), isTrue);
      expect(SecurityAuditService.isPrivilegedSessionAal2({'aal': 'AAL2'}), isTrue);
    });

    test('SecurityAuditService verifies payment webhook idempotency tracking', () {
      final processedEvents = <String>{
        'momo_mtn:evt_001_initial',
        'om_orange:notif_8841_success',
      };

      // Already processed
      expect(
        SecurityAuditService.isEventProcessed(processedEvents, 'evt_001_initial', 'momo_mtn'),
        isTrue,
      );

      // New event
      expect(
        SecurityAuditService.isEventProcessed(processedEvents, 'evt_002_subsequent', 'momo_mtn'),
        isFalse,
      );
    });
  });
}
