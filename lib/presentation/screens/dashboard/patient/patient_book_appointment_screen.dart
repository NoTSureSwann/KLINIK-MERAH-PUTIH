import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/appointment.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/doctor_provider.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class PatientBookAppointmentScreen extends ConsumerStatefulWidget {
  const PatientBookAppointmentScreen({super.key});

  @override
  ConsumerState<PatientBookAppointmentScreen> createState() => _PatientBookAppointmentScreenState();
}

class _PatientBookAppointmentScreenState extends ConsumerState<PatientBookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _complaintsController = TextEditingController();
  String? _selectedDoctorId;

  @override
  void dispose() {
    _dateController.dispose();
    _symptomsController.dispose();
    _complaintsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorProvider);
    final user = ref.watch(authStateProvider).value;
    
    // We assume the user has a linked patient record. 
    // In a real scenario, this would come from the user's profile.
    final patientId = user?.id ?? '1';

    return Scaffold(
      body: Column(
        children: [
          const AppAppBar(
            title: 'Book Appointment',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Select Doctor', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (doctorState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDoctorId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: doctorState.doctors.map((doc) {
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(doc.name),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedDoctorId = val),
                        validator: (val) => val == null ? 'Please select a doctor' : null,
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          _dateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                        }
                      },
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: InputDecoration(
                        hintText: 'Appointment Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      hintText: 'Symptoms (Gejala)',
                      controller: _symptomsController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      hintText: 'Complaints (Keluhan)',
                      controller: _complaintsController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      text: 'Book Appointment',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final appointment = Appointment(
                            id: '',
                            patientId: patientId,
                            doctorId: _selectedDoctorId!,
                            appointmentDate: _dateController.text,
                            status: 'Pending',
                            symptoms: _symptomsController.text,
                            complaints: _complaintsController.text,
                          );
                          ref.read(appointmentProvider.notifier).createAppointment(appointment).then((_) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
