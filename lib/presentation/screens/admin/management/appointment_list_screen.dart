import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_container.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_confirmation_dialog.dart';
import '../../../../shared/widgets/state_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/appointment_provider.dart';

class AppointmentListScreen extends ConsumerWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentState = ref.watch(appointmentProvider);

    return Scaffold(
      body: Container(
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
              title: 'Appointment Management',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => context.push('/admin/appointments/form'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppSearchBar(
                hintText: 'Search by Patient, Doctor, or Status...',
                onChanged: (val) => ref.read(appointmentProvider.notifier).setSearchQuery(val),
              ),
            ),
            Expanded(
              child: _buildBody(context, ref, appointmentState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AppointmentState state) {
    if (state.isLoading && state.appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return ErrorStateIndicator(
        message: state.error!,
        onRetry: () => ref.read(appointmentProvider.notifier).loadAppointments(),
      );
    }

    final filtered = state.filteredAppointments;
    if (filtered.isEmpty) {
      return const EmptyStateIndicator(title: 'No Appointments Found');
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final appointment = filtered[index];
            DateTime? apptDate;
            try {
              apptDate = DateTime.parse(appointment.appointmentDate);
            } catch (_) {}

            final formattedDate = apptDate != null 
              ? DateFormat('dd MMM yyyy, HH:mm').format(apptDate)
              : appointment.appointmentDate;

            return AppContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.calendar_month, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName ?? 'Unknown Patient', 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        Text(
                          'Dr. ${appointment.doctorName ?? 'Unknown Doctor'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/admin/appointments/form', extra: appointment);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AppConfirmationDialog(
                            title: 'Delete Appointment',
                            content: 'Are you sure you want to delete this appointment?',
                            isDestructive: true,
                            confirmText: 'Delete',
                            onConfirm: () => ref.read(appointmentProvider.notifier).deleteAppointment(appointment.id),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        if (state.isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'scheduled':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
