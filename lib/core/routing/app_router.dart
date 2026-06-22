import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/patient_dashboard.dart';
import '../../presentation/screens/dashboard/doctor_dashboard.dart';
import '../../presentation/screens/dashboard/admin_dashboard.dart';

import '../../presentation/screens/dashboard/patient_appointment_screen.dart';
import '../../presentation/screens/dashboard/patient/patient_book_appointment_screen.dart';
import '../../presentation/screens/dashboard/patient_queue_screen.dart';
import '../../presentation/screens/dashboard/patient_profile_screen.dart';
import '../../presentation/screens/dashboard/doctor_patient_list_screen.dart';
import '../../presentation/screens/dashboard/doctor_schedule_screen.dart';
import '../../presentation/screens/dashboard/doctor_profile_screen.dart';
import '../../presentation/screens/dashboard/admin_management_menu_screen.dart';
import '../../presentation/screens/dashboard/admin_reports_screen.dart';
import '../../presentation/screens/dashboard/admin_profile_screen.dart';
import '../../presentation/screens/dashboard/admin/medicine/admin_medicine_list_screen.dart';
import '../../presentation/screens/dashboard/admin/medicine/medicine_form_screen.dart';
import '../../presentation/screens/dashboard/admin/service/admin_service_list_screen.dart';
import '../../presentation/screens/dashboard/admin/service/service_form_screen.dart';
import '../../presentation/screens/dashboard/doctor/medicine/doctor_medicine_screen.dart';
import '../../presentation/screens/dashboard/doctor/service/doctor_service_screen.dart';
import '../../presentation/screens/dashboard/doctor/doctor_medical_records_screen.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/doctor_service.dart';
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
import '../../presentation/screens/admin/management/payment_list_screen.dart';
import '../../presentation/screens/admin/management/payment_form_screen.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/queue.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/payment.dart';
import '../../presentation/providers/auth_provider.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorPatientKey = GlobalKey<NavigatorState>(debugLabel: 'patientShell');
final shellNavigatorDoctorKey = GlobalKey<NavigatorState>(debugLabel: 'doctorShell');
final shellNavigatorAdminKey = GlobalKey<NavigatorState>(debugLabel: 'adminShell');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

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
                builder: (context, state) => const PatientAppointmentScreen(),
                routes: [
                  GoRoute(
                    path: 'book',
                    builder: (context, state) => const PatientBookAppointmentScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/queue',
                builder: (context, state) => const PatientQueueScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/profile',
                builder: (context, state) => const PatientProfileScreen(),
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
                routes: [
                  GoRoute(
                    path: 'medicines',
                    builder: (context, state) => const DoctorMedicineScreen(),
                  ),
                  GoRoute(
                    path: 'services',
                    builder: (context, state) => const DoctorServiceScreen(),
                  ),
                  GoRoute(
                    path: 'medical_records',
                    builder: (context, state) => const DoctorMedicalRecordsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/patients',
                builder: (context, state) => const DoctorPatientListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/schedule',
                builder: (context, state) => const DoctorScheduleScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/profile',
                builder: (context, state) => const DoctorProfileScreen(),
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
                builder: (context, state) => const AdminManagementMenuScreen(),
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
                  GoRoute(
                    path: 'payments',
                    builder: (context, state) => const PaymentListScreen(),
                  ),
                  GoRoute(
                    path: 'payments/form',
                    builder: (context, state) => PaymentFormScreen(payment: state.extra as Payment?),
                  ),
                  GoRoute(
                    path: 'medicines',
                    builder: (context, state) => const AdminMedicineListScreen(),
                  ),
                  GoRoute(
                    path: 'medicines/form',
                    builder: (context, state) => MedicineFormScreen(existingMedicine: state.extra as Medicine?),
                  ),
                  GoRoute(
                    path: 'services',
                    builder: (context, state) => const AdminServiceListScreen(),
                  ),
                  GoRoute(
                    path: 'services/form',
                    builder: (context, state) => ServiceFormScreen(existingService: state.extra as DoctorService?),
                  ),
                ],
              ),            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/reports',
                builder: (context, state) => const AdminReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                builder: (context, state) => const AdminProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
