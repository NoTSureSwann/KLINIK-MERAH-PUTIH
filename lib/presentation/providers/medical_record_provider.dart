import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/medical_record.dart';
import '../../core/network/network_provider.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class MedicalRecordState {
  final bool isLoading;
  final String? error;
  final List<MedicalRecord> records;
  final String searchQuery;

  MedicalRecordState({
    this.isLoading = false,
    this.error,
    this.records = const [],
    this.searchQuery = '',
  });

  MedicalRecordState copyWith({
    bool? isLoading,
    String? error,
    List<MedicalRecord>? records,
    String? searchQuery,
  }) {
    return MedicalRecordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      records: records ?? this.records,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<MedicalRecord> get filteredRecords {
    if (searchQuery.isEmpty) return records;
    final query = searchQuery.toLowerCase();
    return records.where((r) {
      final pName = r.patientName?.toLowerCase() ?? '';
      final dName = r.doctorName?.toLowerCase() ?? '';
      return pName.contains(query) || dName.contains(query) || r.diagnosis.toLowerCase().contains(query);
    }).toList();
  }
}

class MedicalRecordNotifier extends Notifier<MedicalRecordState> {
  late final ApiClient _apiClient;

  @override
  MedicalRecordState build() {
    _apiClient = ref.watch(apiClientProvider);
    Future.microtask(() => loadRecords());
    return MedicalRecordState(isLoading: true);
  }

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_medical_records');
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        final cached = data.map((json) => MedicalRecord(
          id: json['id']?.toString() ?? '',
          appointmentId: json['appointment_id']?.toString() ?? '',
          diagnosis: json['diagnosis'] ?? '',
          prescription: json['prescription'] ?? '',
          notes: json['notes'] ?? '',
          patientName: json['patientName'],
          doctorName: json['doctorName'],
          appointmentDate: json['appointmentDate'],
        )).toList();
        state = state.copyWith(isLoading: false, records: cached);
      }
    } catch (_) {}

    try {
      final response = await _apiClient.get(ApiEndpoints.medicalRecords);
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final records = data.map((json) {
          final appt = json['appointment'] as Map<String, dynamic>?;
          final patient = appt?['patient'] as Map<String, dynamic>?;
          final doctor = appt?['doctor'] as Map<String, dynamic>?;
          final pUser = patient?['user'] as Map<String, dynamic>?;
          final dUser = doctor?['user'] as Map<String, dynamic>?;
          
          return MedicalRecord(
            id: json['id']?.toString() ?? '',
            appointmentId: json['appointment_id']?.toString() ?? '',
            diagnosis: json['diagnosis'] ?? '',
            prescription: json['prescription'] ?? '',
            notes: json['notes'] ?? '',
            patientName: pUser?['name'] ?? patient?['name'],
            doctorName: dUser?['name'] ?? doctor?['name'],
            appointmentDate: appt?['appointment_date'],
          );
        }).toList();

        try {
          final prefs = await SharedPreferences.getInstance();
          final cacheList = records.map((r) => {
            'id': r.id,
            'appointment_id': r.appointmentId,
            'diagnosis': r.diagnosis,
            'prescription': r.prescription,
            'notes': r.notes,
            'patientName': r.patientName,
            'doctorName': r.doctorName,
            'appointmentDate': r.appointmentDate,
          }).toList();
          await prefs.setString('cached_medical_records', jsonEncode(cacheList));
        } catch (_) {}

        state = state.copyWith(isLoading: false, records: records);
      }
    } catch (e) {
      if (state.records.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: e.toString());
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load records: $e');
      }
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createRecord(MedicalRecord record) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.post(ApiEndpoints.medicalRecords, {
        'appointment_id': record.appointmentId,
        'diagnosis': record.diagnosis,
        'prescription': record.prescription,
        'notes': record.notes,
      });
      await loadRecords();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateRecord(MedicalRecord record) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.put('${ApiEndpoints.medicalRecords}/${record.id}', {
        'diagnosis': record.diagnosis,
        'prescription': record.prescription,
        'notes': record.notes,
      });
      await loadRecords();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteRecord(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.delete('${ApiEndpoints.medicalRecords}/$id');
      final updatedList = state.records.where((r) => r.id != id).toList();
      state = state.copyWith(isLoading: false, records: updatedList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final medicalRecordProvider = NotifierProvider<MedicalRecordNotifier, MedicalRecordState>(() {
  return MedicalRecordNotifier();
});
