import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_container.dart';
import '../../providers/appointment_provider.dart';

class PatientAppointmentScreen extends ConsumerWidget {
  const PatientAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentProvider);

    return Column(
      children: [
        AppAppBar(
          title: 'My Appointments',
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.go('/patient/appointment/book');
              },
            )
          ],
        ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)))
                  : state.appointments.isEmpty
                      ? const Center(child: Text('No appointments found. Click + to book.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.appointments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final appointment = state.appointments[index];
                            return AppContainer(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 16,
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(appointment.doctorName ?? 'Unknown Doctor', style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 4),
                                        Text('Date: ${appointment.appointmentDate}', style: Theme.of(context).textTheme.bodyMedium),
                                        if (appointment.symptoms != null && appointment.symptoms!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text('Symptoms: ${appointment.symptoms}', style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                        if (appointment.complaints != null && appointment.complaints!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text('Complaints: ${appointment.complaints}', style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: appointment.status == 'Confirmed' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      appointment.status,
                                      style: TextStyle(
                                        color: appointment.status == 'Confirmed' ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
