import '../../core/network/mock_supabase.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/queue.dart';

class QueueState {
  final bool isLoading;
  final String? error;
  final List<Queue> queues;
  final String searchQuery;

  QueueState({
    this.isLoading = false,
    this.error,
    this.queues = const [],
    this.searchQuery = '',
  });

  QueueState copyWith({
    bool? isLoading,
    String? error,
    List<Queue>? queues,
    String? searchQuery,
  }) {
    return QueueState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      queues: queues ?? this.queues,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Queue> get filteredQueues {
    if (searchQuery.isEmpty) return queues;
    final query = searchQuery.toLowerCase();
    return queues.where((q) {
      final pName = q.patientName?.toLowerCase() ?? '';
      final dName = q.doctorName?.toLowerCase() ?? '';
      return pName.contains(query) || dName.contains(query) || q.queueNumber.toString() == query;
    }).toList();
  }
}

class QueueNotifier extends Notifier<QueueState> {
  final dynamic _supabase = mockSupabase;

  @override
  QueueState build() {
    Future.microtask(() => loadQueues());
    return QueueState(isLoading: true);
  }

  Future<void> loadQueues() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_queues');
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        final cached = data.map((json) => Queue(
          id: json['id']?.toString() ?? '',
          appointmentId: json['appointment_id']?.toString() ?? '',
          queueNumber: json['queue_number'] ?? 0,
          estimatedTime: json['estimated_time'] ?? '',
          status: json['status'] ?? 'Waiting',
          patientName: json['patientName'],
          doctorName: json['doctorName'],
        )).toList();
        state = state.copyWith(isLoading: false, queues: cached);
      }
    } catch (_) {}

    try {
      final data = await _supabase
          .from('queues')
          .select('*, appointments(appointment_date, patients(name), doctors(name))')
          .order('queue_number', ascending: true);

      final queues = data.map((json) {
        final appt = json['appointments'] as Map<String, dynamic>?;
        final patient = appt?['patients'] as Map<String, dynamic>?;
        final doctor = appt?['doctors'] as Map<String, dynamic>?;
        return Queue(
          id: json['id']?.toString() ?? '',
          appointmentId: json['appointment_id']?.toString() ?? '',
          queueNumber: json['queue_number'] ?? 0,
          estimatedTime: json['estimated_time'] ?? '',
          status: json['status'] ?? 'Waiting',
          patientName: patient?['name'],
          doctorName: doctor?['name'],
        );
      }).toList();

      try {
        final prefs = await SharedPreferences.getInstance();
        final cacheList = queues.map((q) => {
          'id': q.id,
          'appointment_id': q.appointmentId,
          'queue_number': q.queueNumber,
          'estimated_time': q.estimatedTime,
          'status': q.status,
          'patientName': q.patientName,
          'doctorName': q.doctorName,
        }).toList();
        await prefs.setString('cached_queues', jsonEncode(cacheList));
      } catch (_) {}

      state = state.copyWith(isLoading: false, queues: queues);
    } catch (e) {
      if (state.queues.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: e.toString());
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load queues: $e');
      }
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createQueue(Queue queue) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('queues').insert({
        'appointment_id': queue.appointmentId,
        'queue_number': queue.queueNumber,
        'estimated_time': queue.estimatedTime,
        'status': queue.status,
      });
      await loadQueues();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateQueue(Queue queue) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('queues').update({
        'queue_number': queue.queueNumber,
        'estimated_time': queue.estimatedTime,
        'status': queue.status,
      }).eq('id', queue.id);
      await loadQueues();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteQueue(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('queues').delete().eq('id', id);
      final updatedList = state.queues.where((q) => q.id != id).toList();
      state = state.copyWith(isLoading: false, queues: updatedList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final queueProvider = NotifierProvider<QueueNotifier, QueueState>(() {
  return QueueNotifier();
});
