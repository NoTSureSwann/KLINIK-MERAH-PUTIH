import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_container.dart';

class PatientQueueScreen extends ConsumerWidget {
  const PatientQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const AppAppBar(
          title: 'Queue Status',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AppContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  borderRadius: 24,
                  child: Column(
                    children: [
                      Text('Your Queue Number', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Text(
                        'A-14',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Waiting',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16,
                        child: Column(
                          children: [
                            Text('Current Queue', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text('A-12', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16,
                        child: Column(
                          children: [
                            Text('Est. Time', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text('15 Mins', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
