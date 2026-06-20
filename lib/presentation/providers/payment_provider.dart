import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/payment.dart';

class PaymentState {
  final bool isLoading;
  final String? error;
  final List<Payment> payments;
  final String searchQuery;

  PaymentState({
    this.isLoading = false,
    this.error,
    this.payments = const [],
    this.searchQuery = '',
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    List<Payment>? payments,
    String? searchQuery,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      payments: payments ?? this.payments,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Payment> get filteredPayments {
    if (searchQuery.isEmpty) return payments;
    final query = searchQuery.toLowerCase();
    return payments.where((p) {
      final pName = p.patientName?.toLowerCase() ?? '';
      final inv = p.invoiceNumber.toLowerCase();
      return pName.contains(query) || inv.contains(query);
    }).toList();
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  final _supabase = Supabase.instance.client;

  @override
  PaymentState build() {
    Future.microtask(() => loadPayments());
    return PaymentState(isLoading: true);
  }

  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_payments');
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        final cached = data.map((json) => Payment(
          id: json['id']?.toString() ?? '',
          patientId: json['patient_id']?.toString() ?? '',
          doctorId: json['doctor_id']?.toString() ?? '',
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          paymentMethod: json['payment_method'] ?? '',
          invoiceNumber: json['invoice_number'] ?? '',
          status: json['status'] ?? 'Pending',
          patientName: json['patientName'],
          doctorName: json['doctorName'],
        )).toList();
        state = state.copyWith(isLoading: false, payments: cached);
      }
    } catch (_) {}

    try {
      final data = await _supabase
          .from('payments')
          .select('*, patients(name), doctors(name)')
          .order('created_at', ascending: false);

      final payments = data.map((json) {
        final patient = json['patients'] as Map<String, dynamic>?;
        final doctor = json['doctors'] as Map<String, dynamic>?;
        return Payment(
          id: json['id']?.toString() ?? '',
          patientId: json['patient_id']?.toString() ?? '',
          doctorId: json['doctor_id']?.toString() ?? '',
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          paymentMethod: json['payment_method'] ?? '',
          invoiceNumber: json['invoice_number'] ?? '',
          status: json['status'] ?? 'Pending',
          patientName: patient?['name'],
          doctorName: doctor?['name'],
        );
      }).toList();

      try {
        final prefs = await SharedPreferences.getInstance();
        final cacheList = payments.map((p) => {
          'id': p.id,
          'patient_id': p.patientId,
          'doctor_id': p.doctorId,
          'amount': p.amount,
          'payment_method': p.paymentMethod,
          'invoice_number': p.invoiceNumber,
          'status': p.status,
          'patientName': p.patientName,
          'doctorName': p.doctorName,
        }).toList();
        await prefs.setString('cached_payments', jsonEncode(cacheList));
      } catch (_) {}

      state = state.copyWith(isLoading: false, payments: payments);
    } catch (e) {
      if (state.payments.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: e.toString());
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load payments: $e');
      }
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createPayment(Payment payment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('payments').insert({
        'patient_id': payment.patientId,
        'doctor_id': payment.doctorId,
        'amount': payment.amount,
        'payment_method': payment.paymentMethod,
        'invoice_number': payment.invoiceNumber,
        'status': payment.status,
      });
      await loadPayments();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePayment(Payment payment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('payments').update({
        'amount': payment.amount,
        'payment_method': payment.paymentMethod,
        'status': payment.status,
      }).eq('id', payment.id);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deletePayment(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('payments').delete().eq('id', id);
      final updatedList = state.payments.where((p) => p.id != id).toList();
      state = state.copyWith(isLoading: false, payments: updatedList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(() {
  return PaymentNotifier();
});
