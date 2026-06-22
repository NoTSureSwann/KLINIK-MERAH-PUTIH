import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/queue.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_container.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/queue_provider.dart';
import '../../../providers/appointment_provider.dart';

class QueueFormScreen extends ConsumerStatefulWidget {
  final Queue? queue;

  const QueueFormScreen({super.key, this.queue});

  @override
  ConsumerState<QueueFormScreen> createState() => _QueueFormScreenState();
}

class _QueueFormScreenState extends ConsumerState<QueueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedAppointmentId;
  final _queueNumberController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  String _status = 'Waiting';

  @override
  void initState() {
    super.initState();
    if (widget.queue != null) {
      _selectedAppointmentId = widget.queue!.appointmentId;
      _queueNumberController.text = widget.queue!.queueNumber.toString();
      _estimatedTimeController.text = widget.queue!.estimatedTime;
      _status = widget.queue!.status;
    }
    
    Future.microtask(() {
      ref.read(appointmentProvider.notifier).loadAppointments();
    });
  }

  @override
  void dispose() {
    _queueNumberController.dispose();
    _estimatedTimeController.dispose();
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

    final queue = Queue(
      id: widget.queue?.id ?? '',
      appointmentId: _selectedAppointmentId!,
      queueNumber: int.tryParse(_queueNumberController.text) ?? 0,
      estimatedTime: _estimatedTimeController.text,
      status: _status,
    );

    if (widget.queue == null) {
      ref.read(queueProvider.notifier).createQueue(queue);
    } else {
      ref.read(queueProvider.notifier).updateQueue(queue);
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
              AppAppBar(
                title: widget.queue == null ? 'Create Queue' : 'Edit Queue',
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
                        
                        AppTextField(
                          controller: _queueNumberController,
                          hintText: 'Queue Number (e.g., 12)',
                          prefixIcon: Icons.format_list_numbered,
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        AppTextField(
                          controller: _estimatedTimeController,
                          hintText: 'Estimated Time (e.g., 10:30 AM)',
                          prefixIcon: Icons.access_time,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),

                        Text('Status', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _status,
                          hint: 'Select Status',
                          items: const [
                            DropdownMenuItem(value: 'Waiting', child: Text('Waiting')),
                            DropdownMenuItem(value: 'In Consultation', child: Text('In Consultation')),
                            DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                          ],
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                        const SizedBox(height: 32),

                        AppButton(
                          text: 'Save Queue',
                          onPressed: _save,
                          isLoading: ref.watch(queueProvider).isLoading,
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
