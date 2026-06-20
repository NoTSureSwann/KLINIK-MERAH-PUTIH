import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/patient.dart';
import '../../../providers/patient_provider.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  final Patient? existingPatient;

  const PatientFormScreen({super.key, this.existingPatient});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _nikCtrl;
  late TextEditingController _addressCtrl;
  
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingPatient?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.existingPatient?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.existingPatient?.phone ?? '');
    _dobCtrl = TextEditingController(text: widget.existingPatient?.birthDate ?? '');
    _nikCtrl = TextEditingController(text: widget.existingPatient?.nik ?? '');
    _addressCtrl = TextEditingController(text: widget.existingPatient?.address ?? '');
    if (widget.existingPatient != null) {
      _gender = widget.existingPatient!.gender;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _nikCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final newPatient = Patient(
        id: widget.existingPatient?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.existingPatient?.userId ?? '2',
        nik: _nikCtrl.text.trim().isEmpty ? '3201123456789000' : _nikCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        birthDate: _dobCtrl.text.trim(),
        gender: _gender,
        address: _addressCtrl.text.trim(),
      );

      if (widget.existingPatient == null) {
        await ref.read(patientProvider.notifier).createPatient(newPatient);
      } else {
        await ref.read(patientProvider.notifier).updatePatient(newPatient);
      }

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPatient != null;
    final isLoading = ref.watch(patientProvider).isLoading;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [AppColors.darkBackgroundTop, AppColors.darkBackgroundMiddle, AppColors.darkBackgroundBottom]
                : [AppColors.backgroundTop, AppColors.backgroundMiddle, AppColors.backgroundBottom],
          ),
        ),
        child: Column(
          children: [
            GlassAppBar(
              title: isEditing ? 'Edit Patient' : 'Create Patient',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Patient Information', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 24),
                        GlassTextField(
                          controller: _nikCtrl,
                          hintText: 'NIK (National ID)',
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          controller: _nameCtrl,
                          hintText: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          controller: _emailCtrl,
                          hintText: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          controller: _phoneCtrl,
                          hintText: 'Phone Number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          controller: _dobCtrl,
                          hintText: 'Date of Birth (YYYY-MM-DD)',
                          prefixIcon: Icons.calendar_today_outlined,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          controller: _addressCtrl,
                          hintText: 'Address',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gender', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _gender,
                                        isExpanded: true,
                                        items: ['Male', 'Female'].map((String value) {
                                          return DropdownMenuItem<String>(value: value, child: Text(value));
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) setState(() => _gender = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        GlassButton(
                          text: isLoading ? 'Saving...' : 'Save Patient',
                          onPressed: isLoading ? () {} : _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
