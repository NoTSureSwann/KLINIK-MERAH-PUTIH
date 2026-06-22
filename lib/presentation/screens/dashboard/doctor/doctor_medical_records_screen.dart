import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/medical_record_provider.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_container.dart';

class DoctorMedicalRecordsScreen extends ConsumerWidget {
  const DoctorMedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicalRecordProvider);

    return Column(
      children: [
        const AppAppBar(
          title: 'Medical Records',
        ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)))
                  : state.records.isEmpty
                      ? const Center(child: Text('No medical records found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.records.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final record = state.records[index];
                            return AppContainer(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Patient: ${record.patientName ?? "Unknown"}', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Date: ${record.appointmentDate ?? "-"}', style: Theme.of(context).textTheme.bodySmall),
                                  const Divider(),
                                  const SizedBox(height: 4),
                                  Text('Diagnosis: ${record.diagnosis}'),
                                  const SizedBox(height: 4),
                                  Text('Prescription: ${record.prescription}'),
                                  if (record.notes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Notes: ${record.notes}'),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
