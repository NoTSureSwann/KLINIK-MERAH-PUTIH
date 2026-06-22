import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/app_app_bar.dart';
import '../../../../../shared/widgets/app_container.dart';
import '../../../../providers/doctor_service_provider.dart';

class DoctorServiceScreen extends ConsumerWidget {
  const DoctorServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(doctorServiceProvider);

    return Column(
      children: [
        const AppAppBar(
          title: 'My Services',
        ),
        Expanded(
          child: services.when(
            data: (serviceList) {
              if (serviceList.isEmpty) {
                return const Center(child: Text('No services available.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: serviceList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final service = serviceList[index];
                  return AppContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.medical_services, color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(service.description, style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 8),
                              Text('Rp ${service.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
