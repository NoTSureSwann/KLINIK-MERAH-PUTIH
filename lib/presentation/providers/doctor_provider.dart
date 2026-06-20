import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/doctor.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Dummy initial data
final _dummyDoctors = [
  const Doctor(id: '1', userId: '5', name: 'Dr. Siti Aminah', specialization: 'General', consultationFee: 50000.0, schedule: 'Mon, Wed, Fri', phone: '081234567890', email: 'siti@example.com'),
  const Doctor(id: '2', userId: '6', name: 'Dr. Budi Santoso', specialization: 'Pediatrician', consultationFee: 75000.0, schedule: 'Tue, Thu, Sat', phone: '081987654321', email: 'budi@example.com'),
];

class DoctorState {
  final bool isLoading;
  final String? error;
  final List<Doctor> doctors;
  final String searchQuery;

  DoctorState({
    this.isLoading = false,
    this.error,
    this.doctors = const [],
    this.searchQuery = '',
  });

  DoctorState copyWith({
    bool? isLoading,
    String? error,
    List<Doctor>? doctors,
    String? searchQuery,
  }) {
    return DoctorState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      doctors: doctors ?? this.doctors,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Doctor> get filteredDoctors {
    if (searchQuery.isEmpty) return doctors;
    return doctors.where((d) => d.name.toLowerCase().contains(searchQuery.toLowerCase()) || d.specialization.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }
}

class DoctorNotifier extends Notifier<DoctorState> {
  final _supabase = Supabase.instance.client;

  @override
  DoctorState build() {
    Future.microtask(() => loadDoctors());
    return DoctorState(isLoading: true);
  }

  Future<void> loadDoctors() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Load from cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_doctors');
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        final cachedDoctors = data.map((json) => Doctor(
          id: json['id']?.toString() ?? '',
          userId: json['user_id']?.toString() ?? '',
          name: json['name'] ?? '',
          email: json['email'] ?? '',
          phone: json['phone'] ?? '',
          specialization: json['specialization'] ?? '',
          consultationFee: json['consultation_fee'] != null ? double.parse(json['consultation_fee'].toString()) : 0.0,
          schedule: json['schedule'] ?? '',
        )).toList();
        state = state.copyWith(isLoading: false, doctors: cachedDoctors);
      }
    } catch (_) {}

    try {
      final data = await _supabase.from('doctors').select().order('created_at', ascending: false);
      final doctors = data.map((json) => Doctor(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        specialization: json['specialization'] ?? '',
        consultationFee: json['consultation_fee'] != null ? double.parse(json['consultation_fee'].toString()) : 0.0,
        schedule: json['schedule'] ?? '',
      )).toList();
      
      // Save to cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_doctors', jsonEncode(data));
      } catch (_) {}

      state = state.copyWith(isLoading: false, doctors: doctors);
      return;
    } catch (e) {
      if (state.doctors.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: e.toString());
        return;
      }
    }

    if (state.doctors.isEmpty) {
      await Future.delayed(const Duration(seconds: 1)); 
      state = state.copyWith(isLoading: false, doctors: List.from(_dummyDoctors));
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createDoctor(Doctor doctor) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _supabase.from('doctors').insert({
        'user_id': doctor.userId.isNotEmpty ? doctor.userId : null,
        'name': doctor.name,
        'email': doctor.email,
        'phone': doctor.phone,
        'specialization': doctor.specialization,
        'consultation_fee': doctor.consultationFee,
        'schedule': doctor.schedule,
      }).select().single();
      
      final newDoctor = Doctor(
        id: data['id']?.toString() ?? doctor.id,
        userId: data['user_id']?.toString() ?? doctor.userId,
        name: data['name'] ?? doctor.name,
        email: data['email'] ?? doctor.email,
        phone: data['phone'] ?? doctor.phone,
        specialization: data['specialization'] ?? doctor.specialization,
        consultationFee: data['consultation_fee'] != null ? double.parse(data['consultation_fee'].toString()) : doctor.consultationFee,
        schedule: data['schedule'] ?? doctor.schedule,
      );
      final updatedList = List<Doctor>.from(state.doctors)..insert(0, newDoctor);
      state = state.copyWith(isLoading: false, doctors: updatedList);
      return;
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));
    final updatedList = List<Doctor>.from(state.doctors)..insert(0, doctor);
    state = state.copyWith(isLoading: false, doctors: updatedList);
  }

  Future<void> updateDoctor(Doctor doctor) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('doctors').update({
        'name': doctor.name,
        'email': doctor.email,
        'phone': doctor.phone,
        'specialization': doctor.specialization,
        'consultation_fee': doctor.consultationFee,
        'schedule': doctor.schedule,
      }).eq('id', doctor.id);
      
      final updatedList = state.doctors.map((d) => d.id == doctor.id ? doctor : d).toList();
      state = state.copyWith(isLoading: false, doctors: updatedList);
      return;
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));
    final updatedList = state.doctors.map((d) => d.id == doctor.id ? doctor : d).toList();
    state = state.copyWith(isLoading: false, doctors: updatedList);
  }

  Future<void> deleteDoctor(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('doctors').delete().eq('id', id);
      final updatedList = state.doctors.where((d) => d.id != id).toList();
      state = state.copyWith(isLoading: false, doctors: updatedList);
      return;
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));
    final updatedList = state.doctors.where((d) => d.id != id).toList();
    state = state.copyWith(isLoading: false, doctors: updatedList);
  }
}

final doctorProvider = NotifierProvider<DoctorNotifier, DoctorState>(() {
  return DoctorNotifier();
});
