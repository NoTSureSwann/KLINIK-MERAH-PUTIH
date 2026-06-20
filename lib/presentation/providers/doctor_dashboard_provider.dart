import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/queue.dart';

class DoctorDashboardState {
  final bool isLoading;
  final String? error;
  final List<Appointment> appointments;
  final List<Queue> queues;
  final int todayAppointmentsCount;
  final int activeQueueCount;

  DoctorDashboardState({
    this.isLoading = false,
    this.error,
    this.appointments = const [],
    this.queues = const [],
    this.todayAppointmentsCount = 0,
    this.activeQueueCount = 0,
  });

  DoctorDashboardState copyWith({
    bool? isLoading,
    String? error,
    List<Appointment>? appointments,
    List<Queue>? queues,
    int? todayAppointmentsCount,
    int? activeQueueCount,
  }) {
    return DoctorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      appointments: appointments ?? this.appointments,
      queues: queues ?? this.queues,
      todayAppointmentsCount: todayAppointmentsCount ?? this.todayAppointmentsCount,
      activeQueueCount: activeQueueCount ?? this.activeQueueCount,
    );
  }
}

class DoctorDashboardNotifier extends Notifier<DoctorDashboardState> {
  final _supabase = Supabase.instance.client;

  @override
  DoctorDashboardState build() {
    Future.microtask(() => loadDashboardData());
    return DoctorDashboardState(isLoading: true);
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'User not logged in');
        return;
      }

      // Find the doctor linked to this user
      final doctorRes = await _supabase.from('doctors').select('id').eq('user_id', user.id).maybeSingle();
      
      if (doctorRes == null) {
        state = state.copyWith(isLoading: false, error: 'Doctor profile not found. Please contact admin.');
        return;
      }
      
      final doctorId = doctorRes['id'];

      // Load appointments
      final apptData = await _supabase
          .from('appointments')
          .select('*, patients(name), doctors(name)')
          .eq('doctor_id', doctorId)
          .order('appointment_date', ascending: true); // upcoming first

      final appointments = apptData.map((json) {
        final pat = json['patients'] as Map<String, dynamic>?;
        final doc = json['doctors'] as Map<String, dynamic>?;
        return Appointment(
          id: json['id']?.toString() ?? '',
          patientId: json['patient_id']?.toString() ?? '',
          doctorId: json['doctor_id']?.toString() ?? '',
          appointmentDate: DateTime.parse(json['appointment_date'] as String),
          status: json['status'] ?? 'Scheduled',
          patientName: pat?['name'],
          doctorName: doc?['name'],
        );
      }).toList();

      // Filter today's appointments
      final today = DateTime.now();
      int todayCount = 0;
      for (var a in appointments) {
        if (a.appointmentDate.year == today.year &&
            a.appointmentDate.month == today.month &&
            a.appointmentDate.day == today.day) {
          todayCount++;
        }
      }

      // Load active queues
      final apptIds = appointments.map((a) => a.id).toList();
      List<Queue> queues = [];
      int activeQCount = 0;
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
          final st = json['status'] ?? 'Waiting';
          if (st != 'Completed') activeQCount++;
          
          return Queue(
            id: json['id']?.toString() ?? '',
            appointmentId: json['appointment_id']?.toString() ?? '',
            queueNumber: json['queue_number'] as int,
            estimatedTime: DateTime.parse(json['estimated_time'] as String),
            status: st,
            patientName: pat?['name'],
            doctorName: doc?['name'],
          );
        }).toList();
      }

      state = state.copyWith(
        isLoading: false,
        appointments: appointments,
        queues: queues,
        todayAppointmentsCount: todayCount,
        activeQueueCount: activeQCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final doctorDashboardProvider = NotifierProvider<DoctorDashboardNotifier, DoctorDashboardState>(() {
  return DoctorDashboardNotifier();
});
