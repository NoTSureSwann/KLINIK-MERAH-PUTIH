import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/patient.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Dummy initial data
final _dummyPatients = [
  const Patient(id: '1', userId: '2', nik: '3201123456789001', name: 'John Doe', email: 'john@example.com', phone: '081234567890', birthDate: '1990-01-01', gender: 'Male', address: 'Jl. Merdeka 1'),
  const Patient(id: '2', userId: '3', nik: '3201123456789002', name: 'Jane Smith', email: 'jane@example.com', phone: '081987654321', birthDate: '1985-05-15', gender: 'Female', address: 'Jl. Mawar 2'),
  const Patient(id: '3', userId: '4', nik: '3201123456789003', name: 'Budi Santoso', email: 'budi@example.com', phone: '081223344556', birthDate: '1970-12-12', gender: 'Male', address: 'Jl. Melati 3'),
];

class PatientState {
  final bool isLoading;
  final String? error;
  final List<Patient> patients;
  final String searchQuery;

  PatientState({
    this.isLoading = false,
    this.error,
    this.patients = const [],
    this.searchQuery = '',
  });

  PatientState copyWith({
    bool? isLoading,
    String? error,
    List<Patient>? patients,
    String? searchQuery,
  }) {
    return PatientState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null, so don't use ?? to allow clearing
      patients: patients ?? this.patients,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Patient> get filteredPatients {
    if (searchQuery.isEmpty) return patients;
    return patients.where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()) || p.nik.contains(searchQuery)).toList();
  }
}

class PatientNotifier extends Notifier<PatientState> {
  final _supabase = Supabase.instance.client;

  @override
  PatientState build() {
    // Initial fetch simulation
    Future.microtask(() => loadPatients());
    return PatientState(isLoading: true);
  }

  Future<void> loadPatients() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Load from cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_patients');
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        final cachedPatients = data.map((json) => Patient(
          id: json['id']?.toString() ?? '',
          userId: json['user_id']?.toString() ?? '',
          nik: json['nik'] ?? '',
          name: json['name'] ?? '',
          email: json['email'] ?? '',
          phone: json['phone'] ?? '',
          birthDate: json['birth_date'] ?? '',
          gender: json['gender'] ?? '',
          address: json['address'] ?? '',
        )).toList();
        state = state.copyWith(isLoading: false, patients: cachedPatients);
      }
    } catch (_) {}

    try {
      final data = await _supabase.from('patients').select().order('created_at', ascending: false);
      final patients = data.map((json) => Patient(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        nik: json['nik'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        birthDate: json['birth_date'] ?? '',
        gender: json['gender'] ?? '',
        address: json['address'] ?? '',
      )).toList();
      
      // Save to cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_patients', jsonEncode(data));
      } catch (_) {}

      state = state.copyWith(isLoading: false, patients: patients);
      return;
    } catch (e) {
      if (state.patients.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: e.toString());
        return;
      }
    }
    
    if (state.patients.isEmpty) {
      // Simulate network delay for dummy
      await Future.delayed(const Duration(seconds: 1)); 
      state = state.copyWith(isLoading: false, patients: List.from(_dummyPatients));
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createPatient(Patient patient) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _supabase.from('patients').insert({
        'user_id': patient.userId.isNotEmpty ? patient.userId : null,
        'nik': patient.nik,
        'name': patient.name,
        'email': patient.email,
        'phone': patient.phone,
        'birth_date': patient.birthDate,
        'gender': patient.gender,
        'address': patient.address,
      }).select().single();
      
      final newPatient = Patient(
        id: data['id']?.toString() ?? patient.id,
        userId: data['user_id']?.toString() ?? patient.userId,
        nik: data['nik'] ?? patient.nik,
        name: data['name'] ?? patient.name,
        email: data['email'] ?? patient.email,
        phone: data['phone'] ?? patient.phone,
        birthDate: data['birth_date'] ?? patient.birthDate,
        gender: data['gender'] ?? patient.gender,
        address: data['address'] ?? patient.address,
      );
      final updatedList = List<Patient>.from(state.patients)..insert(0, newPatient);
      state = state.copyWith(isLoading: false, patients: updatedList);
      return;
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));
    final updatedList = List<Patient>.from(state.patients)..insert(0, patient);
    state = state.copyWith(isLoading: false, patients: updatedList);
  }

  Future<void> updatePatient(Patient patient) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('patients').update({
        'name': patient.name,
        'email': patient.email,
        'phone': patient.phone,
        'birth_date': patient.birthDate,
        'gender': patient.gender,
        'address': patient.address,
      }).eq('id', patient.id);
      
      final updatedList = state.patients.map((p) => p.id == patient.id ? patient : p).toList();
      state = state.copyWith(isLoading: false, patients: updatedList);
      return;
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));
    final updatedList = state.patients.map((p) => p.id == patient.id ? patient : p).toList();
    state = state.copyWith(isLoading: false, patients: updatedList);
  }

  Future<void> deletePatient(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('patients').delete().eq('id', id);
      final updatedList = state.patients.where((p) => p.id != id).toList();
      state = state.copyWith(isLoading: false, patients: updatedList);
      return;
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));
    final updatedList = state.patients.where((p) => p.id != id).toList();
    state = state.copyWith(isLoading: false, patients: updatedList);
  }
}

final patientProvider = NotifierProvider<PatientNotifier, PatientState>(() {
  return PatientNotifier();
});
