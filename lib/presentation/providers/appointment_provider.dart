import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/appointment.dart';

class AppointmentState {
  final bool isLoading;
  final String? error;
  final List<Appointment> appointments;
  final String searchQuery;

  AppointmentState({
    this.isLoading = false,
    this.error,
    this.appointments = const [],
    this.searchQuery = '',
  });

  AppointmentState copyWith({
    bool? isLoading,
    String? error,
    List<Appointment>? appointments,
    String? searchQuery,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      appointments: appointments ?? this.appointments,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Appointment> get filteredAppointments {
    if (searchQuery.isEmpty) return appointments;
    final query = searchQuery.toLowerCase();
    return appointments.where((a) {
      final pName = a.patientName?.toLowerCase() ?? '';
      final dName = a.doctorName?.toLowerCase() ?? '';
      return pName.contains(query) || dName.contains(query) || a.status.toLowerCase().contains(query);
    }).toList();
  }
}

class AppointmentNotifier extends Notifier<AppointmentState> {
  final _supabase = Supabase.instance.client;

  @override
  AppointmentState build() {
    Future.microtask(() => loadAppointments());
    return AppointmentState(isLoading: true);
  }

  Future<void> loadAppointments() async {
    state = state.copyWith(isLoading: true, error: null);

    // Load from cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_appointments');
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        final cachedAppts = data.map((json) => Appointment(
          id: json['id']?.toString() ?? '',
          patientId: json['patient_id']?.toString() ?? '',
          doctorId: json['doctor_id']?.toString() ?? '',
          appointmentDate: json['appointment_date'] ?? '',
          status: json['status'] ?? 'Scheduled',
          patientName: json['patientName'],
          doctorName: json['doctorName'],
        )).toList();
        state = state.copyWith(isLoading: false, appointments: cachedAppts);
      }
    } catch (_) {}

    try {
      // Fetch from Supabase with joins
      final data = await _supabase
          .from('appointments')
          .select('*, patients(name), doctors(name)')
          .order('appointment_date', ascending: false);

      final appointments = data.map((json) {
        final patientMap = json['patients'] as Map<String, dynamic>?;
        final doctorMap = json['doctors'] as Map<String, dynamic>?;
        return Appointment(
          id: json['id']?.toString() ?? '',
          patientId: json['patient_id']?.toString() ?? '',
          doctorId: json['doctor_id']?.toString() ?? '',
          appointmentDate: json['appointment_date'] ?? '',
          status: json['status'] ?? 'Scheduled',
          patientName: patientMap?['name'],
          doctorName: doctorMap?['name'],
        );
      }).toList();

      // Save to cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cacheList = appointments.map((a) => {
          'id': a.id,
          'patient_id': a.patientId,
          'doctor_id': a.doctorId,
          'appointment_date': a.appointmentDate,
          'status': a.status,
          'patientName': a.patientName,
          'doctorName': a.doctorName,
        }).toList();
        await prefs.setString('cached_appointments', jsonEncode(cacheList));
      } catch (_) {}

      state = state.copyWith(isLoading: false, appointments: appointments);
    } catch (e) {
      if (state.appointments.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: e.toString());
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load appointments: $e');
      }
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('appointments').insert({
        'patient_id': appointment.patientId,
        'doctor_id': appointment.doctorId,
        'appointment_date': appointment.appointmentDate,
        'status': appointment.status,
      });
      await loadAppointments(); // Reload to get names via join
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('appointments').update({
        'patient_id': appointment.patientId,
        'doctor_id': appointment.doctorId,
        'appointment_date': appointment.appointmentDate,
        'status': appointment.status,
      }).eq('id', appointment.id);
      await loadAppointments();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAppointment(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('appointments').delete().eq('id', id);
      final updatedList = state.appointments.where((a) => a.id != id).toList();
      state = state.copyWith(isLoading: false, appointments: updatedList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final appointmentProvider = NotifierProvider<AppointmentNotifier, AppointmentState>(() {
  return AppointmentNotifier();
});
