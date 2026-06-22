import '../../core/network/mock_supabase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AnalyticsState {
  final bool isLoading;
  final String? error;
  
  final int totalPatients;
  final int totalDoctors;
  final double dailyRevenue;
  final int activeQueue;
  
  final List<double> dailyVisitsData; // Last 7 days
  final List<double> revenueData; // Last 5 days
  final Map<String, int> queueStats; // By status

  AnalyticsState({
    this.isLoading = false,
    this.error,
    this.totalPatients = 0,
    this.totalDoctors = 0,
    this.dailyRevenue = 0.0,
    this.activeQueue = 0,
    this.dailyVisitsData = const [0, 0, 0, 0, 0, 0, 0],
    this.revenueData = const [0, 0, 0, 0, 0],
    this.queueStats = const {'Waiting': 0, 'In Consultation': 0, 'Completed': 0},
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    int? totalPatients,
    int? totalDoctors,
    double? dailyRevenue,
    int? activeQueue,
    List<double>? dailyVisitsData,
    List<double>? revenueData,
    Map<String, int>? queueStats,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalPatients: totalPatients ?? this.totalPatients,
      totalDoctors: totalDoctors ?? this.totalDoctors,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      activeQueue: activeQueue ?? this.activeQueue,
      dailyVisitsData: dailyVisitsData ?? this.dailyVisitsData,
      revenueData: revenueData ?? this.revenueData,
      queueStats: queueStats ?? this.queueStats,
    );
  }
}

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  final dynamic _supabase = mockSupabase;

  @override
  AnalyticsState build() {
    Future.microtask(() => loadAnalytics());
    return AnalyticsState(isLoading: true);
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final patientsRes = await _supabase.from('patients').select('id');
      final doctorsRes = await _supabase.from('doctors').select('id');
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      
      final paymentsRes = await _supabase.from('payments').select('amount, status, created_at');
      double todayRev = 0;
      List<double> last5DaysRev = [0, 0, 0, 0, 0];
      
      for (var p in paymentsRes) {
        if (p['status'] == 'Paid') {
          final amt = (p['amount'] as num).toDouble();
          final dt = DateTime.parse(p['created_at']);
          if (dt.isAfter(DateTime.parse(startOfDay))) {
            todayRev += amt;
          }
          final diff = today.difference(dt).inDays;
          if (diff >= 0 && diff < 5) {
            last5DaysRev[4 - diff] += amt;
          }
        }
      }

      final queuesRes = await _supabase.from('queues').select('status');
      int actQueue = 0;
      Map<String, int> qStats = {'Waiting': 0, 'In Consultation': 0, 'Completed': 0};
      for (var q in queuesRes) {
        final st = q['status'] as String;
        if (st != 'Completed') actQueue++;
        qStats[st] = (qStats[st] ?? 0) + 1;
      }

      final apptRes = await _supabase.from('appointments').select('appointment_date');
      List<double> visits7Days = [0, 0, 0, 0, 0, 0, 0];
      for (var a in apptRes) {
        final dt = DateTime.parse(a['appointment_date']);
        final diff = today.difference(dt).inDays;
        if (diff >= 0 && diff < 7) {
          visits7Days[6 - diff] += 1;
        }
      }

      state = state.copyWith(
        isLoading: false,
        totalPatients: patientsRes.length,
        totalDoctors: doctorsRes.length,
        dailyRevenue: todayRev,
        activeQueue: actQueue,
        dailyVisitsData: visits7Days,
        revenueData: last5DaysRev,
        queueStats: qStats,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(() {
  return AnalyticsNotifier();
});
