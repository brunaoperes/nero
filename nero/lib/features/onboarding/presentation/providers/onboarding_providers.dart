import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/onboarding_repository_impl.dart';

/// Provider do serviço de onboarding
final onboardingServiceProvider = Provider((ref) {
  return OnboardingRepositoryImpl();
});
