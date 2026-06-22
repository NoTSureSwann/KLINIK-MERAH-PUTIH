import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/medicine.dart';
import '../../core/network/network_provider.dart';

class MedicineNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    return _fetchMedicines();
  }

  Future<List<Medicine>> _fetchMedicines() async {
    final response = await ref.read(apiClientProvider).get('/medicines');
    if (response != null && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Medicine.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> fetchMedicines() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMedicines());
  }

  Future<void> addMedicine(Medicine medicine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiClientProvider).post('/medicines', medicine.toJson());
      final currentList = state.value ?? [];
      if (response != null && response['data'] != null) {
        final newMed = Medicine.fromJson(response['data']);
        return [...currentList, newMed];
      }
      return currentList;
    });
  }

  Future<void> updateMedicine(Medicine medicine) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiClientProvider).put('/medicines/${medicine.id}', medicine.toJson());
      final currentList = state.value ?? [];
      if (response != null && response['data'] != null) {
        final updatedMed = Medicine.fromJson(response['data']);
        return [
          for (final med in currentList)
            if (med.id == updatedMed.id) updatedMed else med
        ];
      }
      return currentList;
    });
  }

  Future<void> deleteMedicine(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiClientProvider).delete('/medicines/$id');
      final currentList = state.value ?? [];
      return currentList.where((med) => med.id != id).toList();
    });
  }
}

final medicineProvider = AsyncNotifierProvider<MedicineNotifier, List<Medicine>>(() {
  return MedicineNotifier();
});
