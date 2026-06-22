import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/app_app_bar.dart';
import '../../../../../shared/widgets/app_container.dart';
import '../../../../providers/medicine_provider.dart';

class DoctorMedicineScreen extends ConsumerWidget {
  const DoctorMedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicineProvider);

    return Column(
      children: [
        const AppAppBar(
          title: 'Medicines Catalog',
        ),
        Expanded(
          child: medicines.when(
            data: (medicineList) {
              if (medicineList.isEmpty) {
                return const Center(child: Text('No medicines available.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: medicineList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final medicine = medicineList[index];
                  return AppContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.medication, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(medicine.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(medicine.description, style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 8),
                              Text('Stock: ${medicine.stock} | Rp ${medicine.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
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
