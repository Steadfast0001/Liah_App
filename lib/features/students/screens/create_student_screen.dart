import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_exception.dart';
import '../models/student_entities.dart';
import '../providers/student_providers.dart';

class CreateStudentScreen extends ConsumerStatefulWidget {
  const CreateStudentScreen({super.key});

  static const routePath = '/students/create';

  @override
  ConsumerState<CreateStudentScreen> createState() =>
      _CreateStudentScreenState();
}

class _CreateStudentScreenState extends ConsumerState<CreateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedProgramId;
  String? _selectedCohortId;
  bool _submitting = false;
  String? _error;
  CreatedStudentResult? _createdResult;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProgramId == null) {
      setState(() => _error = 'Please select an academic program.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
      _createdResult = null;
    });

    try {
      final result = await ref.read(studentRepositoryProvider).createStudent(
            email: _emailController.text.trim(),
            fullName: _fullNameController.text.trim(),
            programId: _selectedProgramId!,
            cohortId: _selectedCohortId,
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          );

      ref.invalidate(studentsListProvider);

      if (!mounted) return;
      setState(() {
        _createdResult = result;
      });
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to create student: $e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(programsListProvider);
    final cohortsAsync = ref.watch(cohortsByProgramProvider(_selectedProgramId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll New Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Student Account & Academic Assignment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Creates a Supabase Auth user, links a profile & student role, and generates an official Liah Academy matricule via the admin-create-student Edge Function.',
                  ),
                  const SizedBox(height: 24),
                  if (_createdResult != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.successText),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.successText,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Student Created Successfully',
                                style: TextStyle(
                                  color: AppColors.successText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Matricule: ${_createdResult!.matricule}',
                            style: const TextStyle(
                              color: AppColors.successText,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          if (_createdResult!.temporaryPassword != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Temporary Password: ${_createdResult!.temporaryPassword}',
                              style: const TextStyle(
                                color: AppColors.successText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              final credentials =
                                  'Matricule: ${_createdResult!.matricule}\n'
                                  'Email: ${_emailController.text.trim()}\n'
                                  'Password: ${_createdResult!.temporaryPassword ?? '(set)'}';
                              Clipboard.setData(
                                ClipboardData(text: credentials),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Credentials copied to clipboard'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Credentials'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v != null && v.trim().length >= 2
                        ? null
                        : 'Enter student full name',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Institutional / Login Email *',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Enter a valid email address',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  programsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (err, _) => Text(
                      'Failed to load programs: $err',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    data: (programs) => DropdownButtonFormField<String>(
                      initialValue: _selectedProgramId,
                      decoration: const InputDecoration(
                        labelText: 'Academic Program *',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: programs
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p.id,
                              child: Text('${p.code} — ${p.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedProgramId = val;
                          _selectedCohortId = null;
                        });
                      },
                      validator: (v) =>
                          v != null ? null : 'Select an academic program',
                    ),
                  ),
                  const SizedBox(height: 16),
                  cohortsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (cohorts) => DropdownButtonFormField<String>(
                      initialValue: _selectedCohortId,
                      decoration: const InputDecoration(
                        labelText: 'Intake Cohort (optional)',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      items: cohorts
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text('${c.label} (${c.intakeYear})'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCohortId = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Initial Password (optional — auto-generated if blank)',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add_alt_1),
                      label: Text(
                        _submitting
                            ? 'Creating Student...'
                            : 'Create Student Account',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
