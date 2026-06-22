import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboard extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdminDashboard({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      drawer: AppDrawer(
        role: 'Admin Loket',
        userName: user?.name ?? 'Admin',
        menuItems: const [
          DrawerMenuItem(title: 'Patients', icon: Icons.personal_injury, route: '/admin/management/patients'),
          DrawerMenuItem(title: 'Doctors', icon: Icons.medical_information, route: '/admin/management/doctors'),
          DrawerMenuItem(title: 'Appointments', icon: Icons.calendar_month, route: '/admin/management/appointments'),
          DrawerMenuItem(title: 'Queues', icon: Icons.people_alt, route: '/admin/management/queues'),
          DrawerMenuItem(title: 'Medical Records', icon: Icons.medical_services, route: '/admin/management/medical_records'),
          DrawerMenuItem(title: 'Payments', icon: Icons.payments, route: '/admin/management/payments'),
          DrawerMenuItem(title: 'Medicines', icon: Icons.medication, route: '/admin/management/medicines'),
          DrawerMenuItem(title: 'Services', icon: Icons.local_hospital, route: '/admin/management/services'),
          DrawerMenuItem(title: 'Settings', icon: Icons.settings, route: '/admin/profile'),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBackgroundTop,
                    AppColors.darkBackgroundMiddle,
                    AppColors.darkBackgroundBottom,
                  ]
                : [
                    AppColors.backgroundTop,
                    AppColors.backgroundMiddle,
                    AppColors.backgroundBottom,
                  ],
          ),
        ),
        child: navigationShell,
      ),
      extendBody: false,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            activeIcon: Icon(Icons.manage_accounts_rounded),
            label: 'Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
