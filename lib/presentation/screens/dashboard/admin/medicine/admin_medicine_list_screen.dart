import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/app_app_bar.dart';
import '../../../../../shared/widgets/app_container.dart';
import '../../../../providers/medicine_provider.dart';

class AdminMedicineListScreen extends ConsumerWidget {
  const AdminMedicineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicineProvider);

    return Scaffold(
      body: Column(
        children: [
          AppAppBar(
            title: 'Manage Medicines',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.push('/admin/management/medicines/form'),
              ),
            ],
          ),
          Expanded(
              child: medicines.when(
                data: (medicineList) {
                  if (medicineList.isEmpty) {
                    return const Center(child: Text('No medicines found.'));
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
                                  Text('Stock: ${medicine.stock} | Rp ${medicine.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => context.push('/admin/management/medicines/form', extra: medicine),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                ref.read(medicineProvider.notifier).deleteMedicine(medicine.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleting...')));
                              },
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
      ),
    );
  }
}
