import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_container.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/doctor.dart';
import '../../../providers/doctor_provider.dart';

class DoctorFormScreen extends ConsumerStatefulWidget {
  final Doctor? existingDoctor;

  const DoctorFormScreen({super.key, this.existingDoctor});

  @override
  ConsumerState<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends ConsumerState<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _specializationCtrl;
  late TextEditingController _feeCtrl;
  late TextEditingController _scheduleCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingDoctor?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.existingDoctor?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.existingDoctor?.phone ?? '');
    _specializationCtrl = TextEditingController(text: widget.existingDoctor?.specialization ?? '');
    _feeCtrl = TextEditingController(text: widget.existingDoctor?.consultationFee.toString() ?? '');
    _scheduleCtrl = TextEditingController(text: widget.existingDoctor?.schedule ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _specializationCtrl.dispose();
    _feeCtrl.dispose();
    _scheduleCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final newDoctor = Doctor(
        id: widget.existingDoctor?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.existingDoctor?.userId ?? '5',
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        specialization: _specializationCtrl.text.trim(),
        consultationFee: double.tryParse(_feeCtrl.text.trim()) ?? 0.0,
        schedule: _scheduleCtrl.text.trim(),
      );

      if (widget.existingDoctor == null) {
        await ref.read(doctorProvider.notifier).createDoctor(newDoctor);
      } else {
        await ref.read(doctorProvider.notifier).updateDoctor(newDoctor);
      }

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDoctor != null;
    final isLoading = ref.watch(doctorProvider).isLoading;

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
            AppAppBar(
              title: isEditing ? 'Edit Doctor' : 'Create Doctor',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: AppContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Doctor Information', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _nameCtrl,
                          hintText: 'Full Name (e.g., Dr. Budi)',
                          prefixIcon: Icons.person_outline,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _specializationCtrl,
                          hintText: 'Specialization',
                          prefixIcon: Icons.medical_services_outlined,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailCtrl,
                          hintText: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _phoneCtrl,
                          hintText: 'Phone Number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _feeCtrl,
                          hintText: 'Consultation Fee',
                          prefixIcon: Icons.attach_money_outlined,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _scheduleCtrl,
                          hintText: 'Schedule (e.g., Mon, Wed, Fri)',
                          prefixIcon: Icons.schedule_outlined,
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 40),
                        AppButton(
                          text: isLoading ? 'Saving...' : 'Save Doctor',
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
