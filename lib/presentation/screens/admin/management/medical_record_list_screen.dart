import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_container.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_confirmation_dialog.dart';
import '../../../../shared/widgets/state_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/medical_record_provider.dart';

class MedicalRecordListScreen extends ConsumerWidget {
  const MedicalRecordListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(medicalRecordProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [AppColors.darkBackgroundTop, AppColors.darkBackgroundMiddle, AppColors.darkBackgroundBottom]
                : [AppColors.backgroundTop, AppColors.backgroundMiddle, AppColors.backgroundBottom],
          ),
        ),
        child: Column(
          children: [
            AppAppBar(
              title: 'Medical Records',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => context.push('/admin/management/medical_records/form'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppSearchBar(
                hintText: 'Search by Patient, Doctor, or Diagnosis...',
                onChanged: (val) => ref.read(medicalRecordProvider.notifier).setSearchQuery(val),
              ),
            ),
            Expanded(
              child: _buildBody(context, ref, recordState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, MedicalRecordState state) {
    if (state.isLoading && state.records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return ErrorStateIndicator(
        message: state.error!,
        onRetry: () => ref.read(medicalRecordProvider.notifier).loadRecords(),
      );
    }

    final filtered = state.filteredRecords;
    if (filtered.isEmpty) {
      return const EmptyStateIndicator(title: 'No Medical Records Found');
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = filtered[index];

            return AppContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.success.withValues(alpha: 0.2),
                    child: const Icon(Icons.medical_services, color: AppColors.success),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.patientName ?? 'Unknown Patient', 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        Text(
                          'Dr. ${record.doctorName ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              record.appointmentDate ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Diagnosis: ${record.diagnosis}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/admin/management/medical_records/form', extra: record);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AppConfirmationDialog(
                            title: 'Delete Record',
                            content: 'Are you sure you want to delete this medical record?',
                            isDestructive: true,
                            confirmText: 'Delete',
                            onConfirm: () => ref.read(medicalRecordProvider.notifier).deleteRecord(record.id),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        if (state.isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
