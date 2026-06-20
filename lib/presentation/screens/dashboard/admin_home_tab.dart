import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_dashboard_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class AdminHomeTab extends ConsumerWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GlassAppBar(
          title: 'Admin Dashboard',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analytics Row
                Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Column(
                          children: [
                            Text('1,245', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primary)),
                            Text('Total Patients', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Column(
                          children: [
                            Text('42', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.secondary)),
                            Text('Total Doctors', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Column(
                          children: [
                            Text('\$12.5k', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.success)),
                            Text('Daily Revenue', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Column(
                          children: [
                            Text('15', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.warning)),
                            Text('Active Queue', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Management Modules
                Text('Management', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    GlassDashboardCard(
                      title: 'Patient\nManagement',
                      value: '',
                      icon: Icons.personal_injury_rounded,
                      iconColor: AppColors.primary,
                      onTap: () => context.go('/admin/patients'),
                    ),
                    GlassDashboardCard(
                      title: 'Doctor\nManagement',
                      value: '',
                      icon: Icons.medical_information_rounded,
                      iconColor: AppColors.secondary,
                      onTap: () => context.go('/admin/doctors'),
                    ),
                    GlassDashboardCard(
                      title: 'Appointment\nManagement',
                      value: '',
                      icon: Icons.calendar_month_rounded,
                      iconColor: AppColors.warning,
                      onTap: () => context.go('/admin/appointments'),
                    ),
                    GlassDashboardCard(
                      title: 'Payment\nManagement',
                      value: '',
                      icon: Icons.payments_rounded,
                      iconColor: AppColors.success,
                      onTap: () => context.go('/admin/payments'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Charts
                Text('Analytics Charts', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Visits (This Week)', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 30),
                                  FlSpot(1, 45),
                                  FlSpot(2, 35),
                                  FlSpot(3, 50),
                                  FlSpot(4, 40),
                                  FlSpot(5, 60),
                                  FlSpot(6, 55),
                                ],
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Revenue', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppColors.success)]),
                                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppColors.success)]),
                                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: AppColors.success)]),
                                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: AppColors.success)]),
                                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: AppColors.success)]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Queue Stats', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 20,
                                  sections: [
                                    PieChartSectionData(color: AppColors.primary, value: 40, title: '', radius: 20),
                                    PieChartSectionData(color: AppColors.secondary, value: 30, title: '', radius: 20),
                                    PieChartSectionData(color: AppColors.warning, value: 15, title: '', radius: 20),
                                    PieChartSectionData(color: AppColors.success, value: 15, title: '', radius: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Reports
                Text('Generate Reports', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: 'Export PDF',
                        icon: Icons.picture_as_pdf_rounded,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generating PDF Report...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassButton(
                        text: 'Export Excel',
                        icon: Icons.table_view_rounded,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generating Excel Report...')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
