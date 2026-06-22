import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_container.dart';
import '../../../shared/widgets/app_button.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppAppBar(
          title: 'Reports & Analytics',
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading Summary Report...')),
                );
              },
            )
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  children: [
                    const Icon(Icons.analytics, size: 60, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text('Monthly Performance', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Revenue increased by 15% this month.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Reports', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: const Text('Patient Demographics (July)'),
                      trailing: SizedBox(width: 100, child: AppButton(text: 'Export', onPressed: () {})),
                    ),
                    ListTile(
                      leading: const Icon(Icons.table_chart),
                      title: const Text('Revenue Details (Q2)'),
                      trailing: SizedBox(width: 100, child: AppButton(text: 'Export', onPressed: () {})),
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_hospital),
                      title: const Text('Doctor Attendance Report'),
                      trailing: SizedBox(width: 100, child: AppButton(text: 'Export', onPressed: () {})),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
