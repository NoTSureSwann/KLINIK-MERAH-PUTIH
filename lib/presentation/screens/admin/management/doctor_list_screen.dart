import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_container.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_confirmation_dialog.dart';
import '../../../../shared/widgets/state_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/doctor_provider.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorState = ref.watch(doctorProvider);

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
              title: 'Doctor Management',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => context.push('/admin/doctors/form'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppSearchBar(
                hintText: 'Search by Name or Specialty...',
                onChanged: (val) => ref.read(doctorProvider.notifier).setSearchQuery(val),
              ),
            ),
            Expanded(
              child: _buildBody(context, ref, doctorState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DoctorState state) {
    if (state.isLoading && state.doctors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return ErrorStateIndicator(
        message: state.error!,
        onRetry: () => ref.read(doctorProvider.notifier).loadDoctors(),
      );
    }

    final filtered = state.filteredDoctors;
    if (filtered.isEmpty) {
      return const EmptyStateIndicator(title: 'No Doctors Found');
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doctor = filtered[index];
            return AppContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                    child: const Icon(Icons.medical_information, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctor.name, style: Theme.of(context).textTheme.titleLarge),
                        Text('${doctor.specialization} | ${doctor.phone}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                    onPressed: () => context.push('/admin/doctors/form', extra: doctor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AppConfirmationDialog(
                          title: 'Delete Doctor',
                          content: 'Are you sure you want to delete ${doctor.name}?',
                          isDestructive: true,
                          confirmText: 'Delete',
                          onConfirm: () => ref.read(doctorProvider.notifier).deleteDoctor(doctor.id),
                        ),
                      );
                    },
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
