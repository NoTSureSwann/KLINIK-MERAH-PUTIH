import '../../core/network/mock_supabase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/entities/queue.dart';

class PatientDashboardState {
  final bool isLoading;
  final String? error;
  final List<Appointment> appointments;
  final List<Queue> queues;

  PatientDashboardState({
    this.isLoading = false,
    this.error,
    this.appointments = const [],
    this.queues = const [],
  });

  PatientDashboardState copyWith({
    bool? isLoading,
    String? error,
    List<Appointment>? appointments,
    List<Queue>? queues,
  }) {
    return PatientDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      appointments: appointments ?? this.appointments,
      queues: queues ?? this.queues,
    );
  }
}

class PatientDashboardNotifier extends Notifier<PatientDashboardState> {
  final dynamic _supabase = mockSupabase;

  @override
  PatientDashboardState build() {
    Future.microtask(() => loadDashboardData());
    return PatientDashboardState(isLoading: true);
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'User not logged in');
        return;
      }

      // Find the patient linked to this user
      final patientRes = await _supabase.from('patients').select('id').eq('user_id', user.id).maybeSingle();
      
      if (patientRes == null) {
        state = state.copyWith(isLoading: false, error: 'Patient profile not found. Please contact admin.');
        return;
      }
      
      final patientId = patientRes['id'];

      // Load their appointments
      final apptData = await _supabase
          .from('appointments')
          .select('*, doctors(name), patients(name)')
          .eq('patient_id', patientId)
          .order('appointment_date', ascending: false);

      final appointments = apptData.map((json) {
        final doc = json['doctors'] as Map<String, dynamic>?;
        final pat = json['patients'] as Map<String, dynamic>?;
        return Appointment(
          id: json['id']?.toString() ?? '',
          patientId: json['patient_id']?.toString() ?? '',
          doctorId: json['doctor_id']?.toString() ?? '',
          appointmentDate: json['appointment_date'] as String,
          status: json['status'] ?? 'Scheduled',
          patientName: pat?['name'],
          doctorName: doc?['name'],
        );
      }).toList();

      // Load their queues
      final apptIds = appointments.map((a) => a.id).toList();
      List<Queue> queues = [];
      if (apptIds.isNotEmpty) {
        final queueData = await _supabase
            .from('queues')
            .select('*, appointments(patients(name), doctors(name))')
            .inFilter('appointment_id', apptIds)
            .order('queue_number', ascending: true);

        queues = queueData.map((json) {
          final appt = json['appointments'] as Map<String, dynamic>?;
          final pat = appt?['patients'] as Map<String, dynamic>?;
          final doc = appt?['doctors'] as Map<String, dynamic>?;
          return Queue(
            id: json['id']?.toString() ?? '',
            appointmentId: json['appointment_id']?.toString() ?? '',
            queueNumber: json['queue_number'] as int,
            estimatedTime: json['estimated_time'] as String,
            status: json['status'] ?? 'Waiting',
            patientName: pat?['name'],
            doctorName: doc?['name'],
          );
        }).toList();
      }

      state = state.copyWith(
        isLoading: false,
        appointments: appointments,
        queues: queues,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final patientDashboardProvider = NotifierProvider<PatientDashboardNotifier, PatientDashboardState>(() {
  return PatientDashboardNotifier();
});
