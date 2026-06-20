import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_bottom_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_drawer.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientDashboard extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const PatientDashboard({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      drawer: GlassDrawer(
        role: 'Patient',
        userName: user?.name ?? 'Guest',
        menuItems: const [
          DrawerMenuItem(title: 'Book Appointment', icon: Icons.calendar_month, route: '/patient/appointment'),
          DrawerMenuItem(title: 'Medical Records', icon: Icons.history, route: '/patient/history'),
          DrawerMenuItem(title: 'Payment History', icon: Icons.payment, route: '/patient/payments'),
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
      extendBody: true,
      bottomNavigationBar: GlassBottomNavigation(
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
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Queue',
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
