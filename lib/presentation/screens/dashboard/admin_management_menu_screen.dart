import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_container.dart';

class AdminManagementMenuScreen extends ConsumerWidget {
  const AdminManagementMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Patients', 'icon': Icons.personal_injury, 'route': '/admin/management/patients'},
      {'title': 'Doctors', 'icon': Icons.medical_information, 'route': '/admin/management/doctors'},
      {'title': 'Appointments', 'icon': Icons.calendar_month, 'route': '/admin/management/appointments'},
      {'title': 'Queues', 'icon': Icons.people_alt, 'route': '/admin/management/queues'},
      {'title': 'Medical Records', 'icon': Icons.medical_services, 'route': '/admin/management/medical_records'},
      {'title': 'Payments', 'icon': Icons.payments, 'route': '/admin/management/payments'},
      {'title': 'Medicines', 'icon': Icons.medication, 'route': '/admin/management/medicines'},
      {'title': 'Services', 'icon': Icons.local_hospital, 'route': '/admin/management/services'},
    ];

    return Column(
      children: [
        const AppAppBar(
          title: 'Management Menu',
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return InkWell(
                onTap: () => context.go(item['route']),
                child: AppContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 40, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        item['title'],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
