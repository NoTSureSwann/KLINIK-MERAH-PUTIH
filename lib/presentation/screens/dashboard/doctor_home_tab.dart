import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_dashboard_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_dashboard_provider.dart';

class DoctorHomeTab extends ConsumerWidget {
  const DoctorHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final dashboardState = ref.watch(doctorDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(doctorDashboardProvider.notifier).loadDashboardData(),
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
                          'Welcome,',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                        ),
                        Text(
                          'Dr. ${user?.name ?? ''}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                      child: const Icon(Icons.medical_information, color: AppColors.secondary, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (dashboardState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (dashboardState.error != null)
                  GlassContainer(
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
                  // Quick Stats
                  Text('Today\'s Overview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlassDashboardCard(
                          title: 'Appointments',
                          value: '${dashboardState.todayAppointmentsCount}',
                          icon: Icons.calendar_today,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassDashboardCard(
                          title: 'Waiting Queue',
                          value: '${dashboardState.activeQueueCount}',
                          icon: Icons.people_alt,
                          iconColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Today's Queue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Queue', style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildQueueList(context, dashboardState),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueList(BuildContext context, DoctorDashboardState state) {
    final activeQueues = state.queues.where((q) => q.status != 'Completed').toList();
    if (activeQueues.isEmpty) {
      return const GlassContainer(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No active queues for you at the moment.')),
      );
    }

    final timeFormat = DateFormat('HH:mm');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeQueues.length > 5 ? 5 : activeQueues.length, // Show up to 5
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final q = activeQueues[index];
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${q.queueNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.patientName ?? 'Unknown Patient',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Est. ${timeFormat.format(DateTime.parse(q.estimatedTime))}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(q.status),
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
        color = Colors.orange;
        break;
      case 'in consultation':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
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
