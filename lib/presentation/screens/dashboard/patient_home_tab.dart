import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/app_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_dashboard_provider.dart';

class PatientHomeTab extends ConsumerWidget {
  const PatientHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final dashboardState = ref.watch(patientDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(patientDashboardProvider.notifier).loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                        ),
                        Text(
                          user?.name ?? 'Patient',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (dashboardState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (dashboardState.error != null)
                  AppContainer(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        dashboardState.error!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  // Active Queue
                  Text('Active Queue', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildActiveQueue(context, dashboardState),

                  const SizedBox(height: 32),

                  // Recent Appointments
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Appointments', style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildAppointments(context, dashboardState),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQueue(BuildContext context, PatientDashboardState state) {
    final activeQueues = state.queues.where((q) => q.status != 'Completed').toList();
    if (activeQueues.isEmpty) {
      return const AppContainer(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        child: Center(child: Text('You have no active queues.')),
      );
    }

    final q = activeQueues.first;
    final timeFormat = DateFormat('HH:mm');

    return AppContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${q.queueNumber}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${q.doctorName ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Est. Time: ${timeFormat.format(DateTime.parse(q.estimatedTime))}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          _buildStatusChip(q.status),
        ],
      ),
    );
  }

  Widget _buildAppointments(BuildContext context, PatientDashboardState state) {
    if (state.appointments.isEmpty) {
      return const AppContainer(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No recent appointments found.')),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.appointments.length > 3 ? 3 : state.appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final a = state.appointments[index];
        return AppContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                child: const Icon(Icons.calendar_today, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${a.doctorName ?? 'Unknown'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dateFormat.format(DateTime.parse(a.appointmentDate)),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(a.status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'waiting':
      case 'scheduled':
        color = Colors.orange;
        break;
      case 'in consultation':
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
