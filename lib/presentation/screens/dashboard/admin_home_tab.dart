import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_dashboard_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/analytics_provider.dart';

class AdminHomeTab extends ConsumerWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

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
          child: RefreshIndicator(
            onRefresh: () => ref.read(analyticsProvider.notifier).loadAnalytics(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analytics Row
                  Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  if (analytics.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        GlassDashboardCard(
                          title: 'Total Patients',
                          value: '${analytics.totalPatients}',
                          icon: Icons.personal_injury_rounded,
                          iconColor: AppColors.primary,
                        ),
                        GlassDashboardCard(
                          title: 'Active Queue',
                          value: '${analytics.activeQueue}',
                          icon: Icons.people_alt_rounded,
                          iconColor: AppColors.secondary,
                        ),
                        GlassDashboardCard(
                          title: 'Daily Revenue',
                          value: currencyFormatter.format(analytics.dailyRevenue),
                          icon: Icons.payments_rounded,
                          iconColor: AppColors.success,
                        ),
                        GlassDashboardCard(
                          title: 'Total Doctors',
                          value: '${analytics.totalDoctors}',
                          icon: Icons.medical_information_rounded,
                          iconColor: AppColors.warning,
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
                        onTap: () => context.go('/admin/management/patients'),
                      ),
                      GlassDashboardCard(
                        title: 'Doctor\nManagement',
                        value: '',
                        icon: Icons.medical_information_rounded,
                        iconColor: AppColors.secondary,
                        onTap: () => context.go('/admin/management/doctors'),
                      ),
                      GlassDashboardCard(
                        title: 'Appointment\nManagement',
                        value: '',
                        icon: Icons.calendar_month_rounded,
                        iconColor: AppColors.warning,
                        onTap: () => context.go('/admin/management/appointments'),
                      ),
                      GlassDashboardCard(
                        title: 'Payment\nManagement',
                        value: '',
                        icon: Icons.payments_rounded,
                        iconColor: AppColors.success,
                        onTap: () => context.go('/admin/management/payments'),
                      ),
                      GlassDashboardCard(
                        title: 'Queue\nManagement',
                        value: '',
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.primary,
                        onTap: () => context.go('/admin/management/queues'),
                      ),
                      GlassDashboardCard(
                        title: 'Medical\nRecords',
                        value: '',
                        icon: Icons.medical_services_rounded,
                        iconColor: AppColors.secondary,
                        onTap: () => context.go('/admin/management/medical_records'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Charts
                  Text('Analytics Charts', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (analytics.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weekly Visits', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: analytics.dailyVisitsData
                                        .asMap()
                                        .entries
                                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                                        .toList(),
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 3,
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
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Revenue (Last 5 Days)', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: analytics.revenueData
                                    .asMap()
                                    .entries
                                    .map((e) => BarChartGroupData(
                                          x: e.key,
                                          barRods: [
                                            BarChartRodData(
                                              toY: e.value,
                                              color: AppColors.success,
                                              width: 16,
                                              borderRadius: BorderRadius.circular(4),
                                            )
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Queue Stats', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 150,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(color: AppColors.primary, value: (analytics.queueStats['Waiting'] ?? 0).toDouble(), title: 'Wait', radius: 30),
                                  PieChartSectionData(color: AppColors.warning, value: (analytics.queueStats['In Consultation'] ?? 0).toDouble(), title: 'In', radius: 30),
                                  PieChartSectionData(color: AppColors.success, value: (analytics.queueStats['Completed'] ?? 0).toDouble(), title: 'Done', radius: 30),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
        ),
      ],
    );
  }
}
