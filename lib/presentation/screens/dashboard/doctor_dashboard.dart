import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorDashboard extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const DoctorDashboard({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      drawer: AppDrawer(
        role: 'Doctor',
        userName: user?.name ?? 'Doctor',
        menuItems: const [
          DrawerMenuItem(title: 'My Schedule', icon: Icons.calendar_today, route: '/doctor/schedule'),
          DrawerMenuItem(title: 'My Patients', icon: Icons.group, route: '/doctor/patients'),
          DrawerMenuItem(title: 'Medicines', icon: Icons.medication, route: '/doctor/medicines'),
          DrawerMenuItem(title: 'Services', icon: Icons.local_hospital, route: '/doctor/services'),
          DrawerMenuItem(title: 'Medical Records', icon: Icons.receipt_long, route: '/doctor/medical_records'),
          DrawerMenuItem(title: 'Settings', icon: Icons.settings, route: '/doctor/profile'),
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
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group_rounded),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: 'Schedule',
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
