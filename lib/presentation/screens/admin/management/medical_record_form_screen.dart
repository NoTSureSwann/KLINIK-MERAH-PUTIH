import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/medical_record.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/medical_record_provider.dart';
import '../../../providers/appointment_provider.dart';

class MedicalRecordFormScreen extends ConsumerStatefulWidget {
  final MedicalRecord? record;

  const MedicalRecordFormScreen({super.key, this.record});

  @override
  ConsumerState<MedicalRecordFormScreen> createState() => _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState extends ConsumerState<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedAppointmentId;
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _selectedAppointmentId = widget.record!.appointmentId;
      _diagnosisController.text = widget.record!.diagnosis;
      _prescriptionController.text = widget.record!.prescription;
      _notesController.text = widget.record!.notes;
    }
    
    Future.microtask(() {
      ref.read(appointmentProvider.notifier).loadAppointments();
    });
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAppointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an appointment')),
      );
      return;
    }

    final record = MedicalRecord(
      id: widget.record?.id ?? '',
      appointmentId: _selectedAppointmentId!,
      diagnosis: _diagnosisController.text,
      prescription: _prescriptionController.text,
      notes: _notesController.text,
    );

    if (widget.record == null) {
      ref.read(medicalRecordProvider.notifier).createRecord(record);
    } else {
      ref.read(medicalRecordProvider.notifier).updateRecord(record);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              GlassAppBar(
                title: widget.record == null ? 'Create Medical Record' : 'Edit Medical Record',
                showBackButton: true,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appointment', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _selectedAppointmentId,
                          hint: 'Select Appointment',
                          items: appointmentState.appointments.map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text('${a.patientName} - Dr. ${a.doctorName}'),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedAppointmentId = val),
                        ),
                        const SizedBox(height: 20),
                        
                        GlassTextField(
                          controller: _diagnosisController,
                          hintText: 'Diagnosis',
                          prefixIcon: Icons.medical_services,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        GlassTextField(
                          controller: _prescriptionController,
                          hintText: 'Prescription',
                          prefixIcon: Icons.medication,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        GlassTextField(
                          controller: _notesController,
                          hintText: 'Notes',
                          prefixIcon: Icons.notes,
                          maxLines: 3,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 32),

                        GlassButton(
                          text: 'Save Record',
                          onPressed: _save,
                          isLoading: ref.watch(medicalRecordProvider).isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400)),
          isExpanded: true,
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
