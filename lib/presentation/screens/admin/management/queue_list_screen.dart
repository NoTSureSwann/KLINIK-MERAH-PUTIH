import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_search_bar.dart';
import '../../../../shared/widgets/glass_confirmation_dialog.dart';
import '../../../../shared/widgets/state_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/queue_provider.dart';

class QueueListScreen extends ConsumerWidget {
  const QueueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueProvider);

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
            GlassAppBar(
              title: 'Queue Management',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => context.push('/admin/management/queues/form'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassSearchBar(
                hintText: 'Search by Name, Doctor, or Number...',
                onChanged: (val) => ref.read(queueProvider.notifier).setSearchQuery(val),
              ),
            ),
            Expanded(
              child: _buildBody(context, ref, queueState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, QueueState state) {
    if (state.isLoading && state.queues.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return ErrorStateIndicator(
        message: state.error!,
        onRetry: () => ref.read(queueProvider.notifier).loadQueues(),
      );
    }

    final filtered = state.filteredQueues;
    if (filtered.isEmpty) {
      return const EmptyStateIndicator(title: 'No Queues Found');
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final queue = filtered[index];

            return GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        queue.queueNumber.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          queue.patientName ?? 'Unknown Patient', 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        Text(
                          'Dr. ${queue.doctorName ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Est: ${queue.estimatedTime}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(queue.status),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/admin/management/queues/form', extra: queue);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => GlassConfirmationDialog(
                            title: 'Delete Queue',
                            content: 'Are you sure you want to delete queue number ${queue.queueNumber}?',
                            isDestructive: true,
                            confirmText: 'Delete',
                            onConfirm: () => ref.read(queueProvider.notifier).deleteQueue(queue.id),
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

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'waiting':
        color = Colors.orange;
        break;
      case 'in consultation':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
