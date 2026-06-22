import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../../../shared/widgets/glass_bottom_navigation.dart';
import '../../../shared/widgets/glass_dashboard_card.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBackgroundTop,
                    AppColors.darkBackgroundMiddle,
                    AppColors.darkBackgroundBottom,
                  ]
                : [
                    AppColors.backgroundTop,
                    AppColors.backgroundMiddle,
                    AppColors.backgroundBottom,
                  ],
          ),
        ),
        child: Column(
          children: [
            GlassAppBar(
              title: 'Dashboard',
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Hero(
                  tag: 'app_logo',
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              actions: [
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
                      Text(
                        'Hello, ${user?.name ?? 'Guest'}',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        'Role: ${user?.role ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          GlassDashboardCard(
                            title: 'Total Patients',
                            value: '1,245',
                            icon: Icons.people_outline,
                            iconColor: AppColors.primary,
                            onTap: () {},
                          ),
                          GlassDashboardCard(
                            title: 'Appointments',
                            value: '48',
                            icon: Icons.calendar_today_outlined,
                            iconColor: AppColors.secondary,
                            onTap: () {},
                          ),
                          GlassDashboardCard(
                            title: 'Revenue',
                            value: '\$12k',
                            icon: Icons.attach_money,
                            iconColor: AppColors.success,
                            onTap: () {},
                          ),
                          GlassDashboardCard(
                            title: 'Alerts',
                            value: '3',
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.warning,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 24,
                        child: Column(
                          children: List.generate(
                            3,
                            (index) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: AppColors.primary),
                              ),
                              title: const Text('Patient Registration'),
                              subtitle: const Text('2 mins ago'),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: false,
      bottomNavigationBar: GlassBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
