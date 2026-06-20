import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/glass_dashboard_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class PatientHomeTab extends ConsumerWidget {
  const PatientHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Column(
      children: [
        GlassAppBar(
          title: 'Dashboard',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              color: Theme.of(context).colorScheme.error,
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: userAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Profile Header
                  Text(
                    'Good Morning,',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    user?.name ?? 'Guest',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 24),

                  // Profile Card
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 24,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          child: Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Medical ID: RM-10293', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Active Member', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4 Grid Dashboard Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      GlassDashboardCard(
                        title: 'Book\nAppointment',
                        value: '',
                        icon: Icons.calendar_month_rounded,
                        iconColor: AppColors.primary,
                        onTap: () {},
                      ),
                      GlassDashboardCard(
                        title: 'Today\'s\nQueue',
                        value: '',
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.secondary,
                        onTap: () {},
                      ),
                      GlassDashboardCard(
                        title: 'Payment\nStatus',
                        value: '',
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.warning,
                        onTap: () {},
                      ),
                      GlassDashboardCard(
                        title: 'Medical\nHistory',
                        value: '',
                        icon: Icons.history_rounded,
                        iconColor: AppColors.success,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Upcoming Appointment Card
                  Text('Upcoming Appointment', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 24,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text('15', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              Text('OCT', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dr. Siti Aminah', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text('09:00 AM - 10:00 AM', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Upcoming', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Queue Card
                  Text('Your Live Queue', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Queue Number', style: Theme.of(context).textTheme.bodyMedium),
                                Text('A-12', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary)),
                              ],
                            ),
                            Icon(Icons.qr_code_2_rounded, size: 80, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Est. Wait Time', style: Theme.of(context).textTheme.bodyMedium),
                            Text('~15 mins', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Activities
                  Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: 24,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.check_circle_outline, color: AppColors.success),
                          title: const Text('Consultation Completed'),
                          subtitle: const Text('Dr. Budi - 10 Oct 2023'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.payment_rounded, color: AppColors.primary),
                          title: const Text('Payment Successful'),
                          subtitle: const Text('Inv-0012 - 10 Oct 2023'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
