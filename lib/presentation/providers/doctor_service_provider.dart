import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/doctor_service.dart';
import '../../core/network/network_provider.dart';

class DoctorServiceNotifier extends AsyncNotifier<List<DoctorService>> {
  @override
  Future<List<DoctorService>> build() async {
    return _fetchServices();
  }

  Future<List<DoctorService>> _fetchServices() async {
    final response = await ref.read(apiClientProvider).get('/services');
    if (response != null && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => DoctorService.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> fetchServices() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchServices());
  }

  Future<void> addService(DoctorService service) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiClientProvider).post('/services', service.toJson());
      final currentList = state.value ?? [];
      if (response != null && response['data'] != null) {
        final newSvc = DoctorService.fromJson(response['data']);
        return [...currentList, newSvc];
      }
      return currentList;
    });
  }

  Future<void> updateService(DoctorService service) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiClientProvider).put('/services/${service.id}', service.toJson());
      final currentList = state.value ?? [];
      if (response != null && response['data'] != null) {
        final updatedSvc = DoctorService.fromJson(response['data']);
        return [
          for (final svc in currentList)
            if (svc.id == updatedSvc.id) updatedSvc else svc
        ];
      }
      return currentList;
    });
  }

  Future<void> deleteService(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiClientProvider).delete('/services/$id');
      final currentList = state.value ?? [];
      return currentList.where((svc) => svc.id != id).toList();
    });
  }
}

final doctorServiceProvider = AsyncNotifierProvider<DoctorServiceNotifier, List<DoctorService>>(() {
  return DoctorServiceNotifier();
});
