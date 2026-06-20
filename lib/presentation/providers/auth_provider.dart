import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';
class SplashNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void finish() => state = true;
}

final splashFinishedProvider = NotifierProvider<SplashNotifier, bool>(() {
  return SplashNotifier();
});

// Onboarding State
class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'onboarding_finished';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, true);
    state = true;
  }
}

final onboardingFinishedProvider = NotifierProvider<OnboardingNotifier, bool>(() {
  return OnboardingNotifier();
});

// SharedPreferences and Repository
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Override in main.dart
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepository(prefs);
});

// Auth State
class AuthNotifier extends AsyncNotifier<User?> {
  late AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return _repository.getCurrentUser();
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      if (user != null) {
        state = AsyncValue.data(user);
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String phone, String role) async {
    state = const AsyncValue.loading();
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Forward to Supabase via repository
    try {
      final newUser = await _repository.register(name, email, password, phone, role);
      state = AsyncValue.data(newUser);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});
