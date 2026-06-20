import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/dashboard/patient_dashboard.dart';
import '../../presentation/screens/dashboard/doctor_dashboard.dart';
import '../../presentation/screens/dashboard/admin_dashboard.dart';
import '../../presentation/screens/dashboard/placeholder_screen.dart';
import '../../presentation/screens/dashboard/patient_home_tab.dart';
import '../../presentation/screens/dashboard/doctor_home_tab.dart';
import '../../presentation/screens/dashboard/admin_home_tab.dart';
import '../../presentation/screens/admin/management/patient_list_screen.dart';
import '../../presentation/screens/admin/management/patient_form_screen.dart';
import '../../presentation/screens/admin/management/doctor_list_screen.dart';
import '../../presentation/screens/admin/management/doctor_form_screen.dart';
import '../../presentation/screens/admin/management/appointment_list_screen.dart';
import '../../presentation/screens/admin/management/appointment_form_screen.dart';
import '../../presentation/screens/admin/management/queue_list_screen.dart';
import '../../presentation/screens/admin/management/queue_form_screen.dart';
import '../../presentation/screens/admin/management/medical_record_list_screen.dart';
import '../../presentation/screens/admin/management/medical_record_form_screen.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/queue.dart';
import '../../domain/entities/medical_record.dart';
import '../../presentation/providers/auth_provider.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorPatientKey = GlobalKey<NavigatorState>(debugLabel: 'patientShell');
final shellNavigatorDoctorKey = GlobalKey<NavigatorState>(debugLabel: 'doctorShell');
final shellNavigatorAdminKey = GlobalKey<NavigatorState>(debugLabel: 'adminShell');

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isSplashFinished = ref.watch(splashFinishedProvider);
  final isOnboardingFinished = ref.watch(onboardingFinishedProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      if (!isSplashFinished) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      if (!isOnboardingFinished) {
        return state.matchedLocation == '/onboarding' ? null : '/onboarding';
      }

      final isLoading = authState.isLoading;
      final isAuthenticated = authState.value != null;
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (isLoading) return null;

      if (!isAuthenticated && !isGoingToAuth) {
        return '/login';
      }

      if (isAuthenticated && isGoingToAuth) {
        final role = authState.value?.role;
        if (role == 'Doctor') return '/doctor';
        if (role == 'Admin Loket') return '/admin';
        return '/patient';
      }

      if (isAuthenticated && state.matchedLocation == '/') {
        final role = authState.value?.role;
        if (role == 'Doctor') return '/doctor';
        if (role == 'Admin Loket') return '/admin';
        return '/patient';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
          },
        ),
      ),

      // --- PATIENT ROUTES ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => PatientDashboard(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient',
                builder: (context, state) => const PatientHomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/appointment',
                builder: (context, state) => const PlaceholderScreen(title: 'Appointments', icon: Icons.calendar_month),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/queue',
                builder: (context, state) => const PlaceholderScreen(title: 'Queue Status', icon: Icons.people_alt),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/profile',
                builder: (context, state) => const PlaceholderScreen(title: 'Profile', icon: Icons.person),
              ),
            ],
          ),
        ],
      ),

      // --- DOCTOR ROUTES ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => DoctorDashboard(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor',
                builder: (context, state) => const DoctorHomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/patients',
                builder: (context, state) => const PlaceholderScreen(title: 'Patient List', icon: Icons.group),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/schedule',
                builder: (context, state) => const PlaceholderScreen(title: 'Schedule', icon: Icons.calendar_today),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/profile',
                builder: (context, state) => const PlaceholderScreen(title: 'Profile', icon: Icons.person),
              ),
            ],
          ),
        ],
      ),

      // --- ADMIN ROUTES ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdminDashboard(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminHomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/management',
                builder: (context, state) => const PlaceholderScreen(title: 'Management', icon: Icons.manage_accounts),
                routes: [
                  GoRoute(
                    path: 'patients',
                    builder: (context, state) => const PatientListScreen(),
                  ),
                  GoRoute(
                    path: 'patients/form',
                    builder: (context, state) => PatientFormScreen(existingPatient: state.extra as Patient?),
                  ),
                  GoRoute(
                    path: 'doctors',
                    builder: (context, state) => const DoctorListScreen(),
                  ),
                  GoRoute(
                    path: 'doctors/form',
                    builder: (context, state) => DoctorFormScreen(existingDoctor: state.extra as Doctor?),
                  ),
                  GoRoute(
                    path: 'appointments',
                    builder: (context, state) => const AppointmentListScreen(),
                  ),
                  GoRoute(
                    path: 'appointments/form',
                    builder: (context, state) => AppointmentFormScreen(appointment: state.extra as Appointment?),
                  ),
                  GoRoute(
                    path: 'queues',
                    builder: (context, state) => const QueueListScreen(),
                  ),
                  GoRoute(
                    path: 'queues/form',
                    builder: (context, state) => QueueFormScreen(queue: state.extra as Queue?),
                  ),
                  GoRoute(
                    path: 'medical_records',
                    builder: (context, state) => const MedicalRecordListScreen(),
                  ),
                  GoRoute(
                    path: 'medical_records/form',
                    builder: (context, state) => MedicalRecordFormScreen(record: state.extra as MedicalRecord?),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/reports',
                builder: (context, state) => const PlaceholderScreen(title: 'Reports', icon: Icons.analytics),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                builder: (context, state) => const PlaceholderScreen(title: 'Profile', icon: Icons.person),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
