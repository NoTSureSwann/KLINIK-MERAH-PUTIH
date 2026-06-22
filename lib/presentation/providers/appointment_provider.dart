import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/appointment.dart';
import '../../core/network/network_provider.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

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
  late final ApiClient _apiClient;

  @override
  AppointmentState build() {
    _apiClient = ref.watch(apiClientProvider);
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
          symptoms: json['symptoms'],
          complaints: json['complaints'],
        )).toList();
        state = state.copyWith(isLoading: false, appointments: cachedAppts);
      }
    } catch (_) {}

    try {
      final response = await _apiClient.get(ApiEndpoints.appointments);
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final appointments = data.map((json) {
          final patientMap = json['patient'] as Map<String, dynamic>?;
          final doctorMap = json['doctor'] as Map<String, dynamic>?;
          final pUser = patientMap?['user'] as Map<String, dynamic>?;
          final dUser = doctorMap?['user'] as Map<String, dynamic>?;
          return Appointment(
            id: json['id']?.toString() ?? '',
            patientId: json['patient_id']?.toString() ?? '',
            doctorId: json['doctor_id']?.toString() ?? '',
            appointmentDate: json['appointment_date'] ?? '',
            status: json['status'] ?? 'Pending',
            patientName: pUser?['name'] ?? patientMap?['name'],
            doctorName: dUser?['name'] ?? doctorMap?['name'],
            symptoms: json['symptoms'],
            complaints: json['complaints'],
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
            'symptoms': a.symptoms,
            'complaints': a.complaints,
          }).toList();
          await prefs.setString('cached_appointments', jsonEncode(cacheList));
        } catch (_) {}

        state = state.copyWith(isLoading: false, appointments: appointments);
      }
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
      await _apiClient.post(ApiEndpoints.appointments, {
        'patient_id': appointment.patientId,
        'doctor_id': appointment.doctorId,
        'appointment_date': appointment.appointmentDate,
        'symptoms': appointment.symptoms,
        'complaints': appointment.complaints,
      });
      await loadAppointments(); 
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.put('${ApiEndpoints.appointments}/${appointment.id}', {
        'patient_id': appointment.patientId,
        'doctor_id': appointment.doctorId,
        'appointment_date': appointment.appointmentDate,
        'status': appointment.status,
        'symptoms': appointment.symptoms,
        'complaints': appointment.complaints,
      });
      await loadAppointments();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAppointment(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.delete('${ApiEndpoints.appointments}/$id');
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
