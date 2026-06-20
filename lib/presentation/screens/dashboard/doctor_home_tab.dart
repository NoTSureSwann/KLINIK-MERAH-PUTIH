import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/glass_dashboard_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class DoctorHomeTab extends ConsumerWidget {
  const DoctorHomeTab({super.key});

  void _showMedicalRecordForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MedicalRecordFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Column(
      children: [
        GlassAppBar(
          title: 'Doctor Portal',
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
                  // Greeting Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ${user?.name ?? 'Doctor'}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('General Practitioner', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Statistics Row
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Column(
                            children: [
                              Text('24', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primary)),
                              Text('Total', style: Theme.of(context).textTheme.bodySmall),
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
                              Text('8', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.warning)),
                              Text('Waiting', style: Theme.of(context).textTheme.bodySmall),
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
                              Text('16', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.success)),
                              Text('Done', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active Queue Card
                  Text('Current Patient', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    borderColor: AppColors.primary.withValues(alpha: 0.5),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Queue Number', style: Theme.of(context).textTheme.bodyMedium),
                                Text('A-05', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary)),
                                const SizedBox(height: 4),
                                Text('Budi Santoso', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 32),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: GlassButton(
                                text: 'Consultation',
                                icon: Icons.edit_document,
                                onPressed: () => _showMedicalRecordForm(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GlassContainer(
                              height: 56,
                              width: 56,
                              borderRadius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.skip_next_rounded, color: AppColors.primary),
                                onPressed: () {}, // Next Queue
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4 Grid Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      GlassDashboardCard(
                        title: 'Patient\nList',
                        value: '',
                        icon: Icons.group_rounded,
                        iconColor: AppColors.primary,
                        onTap: () {},
                      ),
                      GlassDashboardCard(
                        title: 'My\nSchedule',
                        value: '',
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.secondary,
                        onTap: () {},
                      ),
                      GlassDashboardCard(
                        title: 'Medical\nRecords',
                        value: '',
                        icon: Icons.folder_shared_rounded,
                        iconColor: AppColors.warning,
                        onTap: () {},
                      ),
                      GlassDashboardCard(
                        title: 'Queue\nManagement',
                        value: '',
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.success,
                        onTap: () {},
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

class MedicalRecordFormSheet extends StatelessWidget {
  const MedicalRecordFormSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 60,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        borderRadius: 32,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Medical Record', style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const GlassTextField(
                      hintText: 'Diagnosis',
                      prefixIcon: Icons.medical_services_outlined,
                    ),
                    const SizedBox(height: 16),
                    const GlassTextField(
                      hintText: 'Prescription',
                      prefixIcon: Icons.medication_outlined,
                    ),
                    const SizedBox(height: 16),
                    GlassContainer(
                      height: 120,
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Additional Notes',
                          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassButton(
                      text: 'Save Record',
                      icon: Icons.save_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
