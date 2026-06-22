import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/appointment.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_container.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../../providers/doctor_provider.dart';

class AppointmentFormScreen extends ConsumerStatefulWidget {
  final Appointment? appointment;

  const AppointmentFormScreen({super.key, this.appointment});

  @override
  ConsumerState<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends ConsumerState<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedPatientId;
  String? _selectedDoctorId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _status = 'Scheduled';

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _selectedPatientId = widget.appointment!.patientId;
      _selectedDoctorId = widget.appointment!.doctorId;
      _status = widget.appointment!.status;
      try {
        final dt = DateTime.parse(widget.appointment!.appointmentDate);
        _selectedDate = dt;
        _selectedTime = TimeOfDay.fromDateTime(dt);
      } catch (_) {}
    }
    
    // Load patients and doctors if not loaded
    Future.microtask(() {
      ref.read(patientProvider.notifier).loadPatients();
      ref.read(doctorProvider.notifier).loadDoctors();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null || _selectedDoctorId == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final appointmentDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    ).toIso8601String();

    final appointment = Appointment(
      id: widget.appointment?.id ?? '',
      patientId: _selectedPatientId!,
      doctorId: _selectedDoctorId!,
      appointmentDate: appointmentDate,
      status: _status,
    );

    if (widget.appointment == null) {
      await ref.read(appointmentProvider.notifier).createAppointment(appointment);
    } else {
      await ref.read(appointmentProvider.notifier).updateAppointment(appointment);
    }

    if (mounted) {
      final appointmentState = ref.read(appointmentProvider);
      if (appointmentState.error != null) {
        final errorMsg = appointmentState.error!.replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientProvider);
    final doctorState = ref.watch(doctorProvider);
    
    final dateText = _selectedDate != null 
        ? DateFormat('dd MMM yyyy').format(_selectedDate!) 
        : 'Select Date';
        
    final timeText = _selectedTime != null 
        ? _selectedTime!.format(context) 
        : 'Select Time';

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
              AppAppBar(
                title: widget.appointment == null ? 'Create Appointment' : 'Edit Appointment',
                showBackButton: true,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: AppContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Patient', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _selectedPatientId,
                          hint: 'Select Patient',
                          items: patientState.patients.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} (${p.nik})'),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedPatientId = val),
                        ),
                        const SizedBox(height: 20),
                        
                        Text('Doctor', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _selectedDoctorId,
                          hint: 'Select Doctor',
                          items: doctorState.doctors.map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text('${d.name} (${d.specialization})'),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedDoctorId = val),
                        ),
                        const SizedBox(height: 20),
                        
                        Text('Date & Time', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(() => _selectedDate = date);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(dateText),
                                      const Icon(Icons.calendar_today, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime ?? TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() => _selectedTime = time);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(timeText),
                                      const Icon(Icons.access_time, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Text('Status', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _status,
                          hint: 'Select Status',
                          items: const [
                            DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                            DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                            DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                        const SizedBox(height: 32),

                        AppButton(
                          text: 'Save Appointment',
                          onPressed: _save,
                          isLoading: ref.watch(appointmentProvider).isLoading,
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
