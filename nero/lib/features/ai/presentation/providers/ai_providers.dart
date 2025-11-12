import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/app_logger.dart';

/// Provider do AIService
final aiServiceProvider = Provider<AIService>((ref) => AIService());

/// Provider de recomendações do usuário
final recommendationsProvider = FutureProvider<List<AIRecommendation>>((ref) async {
  final aiService = ref.read(aiServiceProvider);
  final userId = SupabaseService.currentUser?.id ?? '';

  if (userId.isEmpty) return [];

  try {
    return await aiService.getUserRecommendations(
      userId: userId,
      includeRead: false,
      includeDismissed: false,
    );
  } catch (e, stack) {
    AppLogger.error('Erro ao buscar recomendações', error: e, stackTrace: stack);
    return [];
  }
});

/// Provider de estatísticas de recomendações
final recommendationStatsProvider = FutureProvider<RecommendationStats>((ref) async {
  final aiService = ref.read(aiServiceProvider);
  final userId = SupabaseService.currentUser?.id ?? '';

  if (userId.isEmpty) {
    return RecommendationStats(
      total: 0,
      unread: 0,
      dismissed: 0,
      accepted: 0,
      completed: 0,
      rejected: 0,
      byType: {},
      byPriority: {},
    );
  }

  try {
    return await aiService.getRecommendationStats(userId);
  } catch (e, stack) {
    AppLogger.error('Erro ao buscar estatísticas de recomendações', error: e, stackTrace: stack);
    return RecommendationStats(
      total: 0,
      unread: 0,
      dismissed: 0,
      accepted: 0,
      completed: 0,
      rejected: 0,
      byType: {},
      byPriority: {},
    );
  }
});

/// StateNotifier para gerenciar ações de recomendações
class RecommendationsNotifier extends StateNotifier<AsyncValue<List<AIRecommendation>>> {
  final AIService _aiService;
  final String _userId;

  RecommendationsNotifier(this._aiService, this._userId)
      : super(const AsyncValue.loading()) {
    loadRecommendations();
  }

  /// Carrega recomendações
  Future<void> loadRecommendations() async {
    state = const AsyncValue.loading();
    try {
      final recommendations = await _aiService.getUserRecommendations(
        userId: _userId,
        includeRead: false,
        includeDismissed: false,
      );
      state = AsyncValue.data(recommendations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Aceita uma recomendação
  Future<bool> acceptRecommendation(String recommendationId) async {
    try {
      await _aiService.acceptRecommendation(recommendationId, _userId);
      await loadRecommendations();
      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao aceitar recomendação', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Rejeita uma recomendação
  Future<bool> rejectRecommendation(String recommendationId) async {
    try {
      await _aiService.rejectRecommendation(recommendationId, _userId);
      await loadRecommendations();
      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao rejeitar recomendação', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Completa uma recomendação
  Future<bool> completeRecommendation(String recommendationId) async {
    try {
      await _aiService.completeRecommendation(recommendationId, _userId);
      await loadRecommendations();
      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao completar recomendação', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Dispensa uma recomendação
  Future<bool> dismissRecommendation(String recommendationId) async {
    try {
      await _aiService.dismissRecommendation(recommendationId, _userId);
      await loadRecommendations();
      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao dispensar recomendação', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Marca como lida
  Future<bool> markAsRead(String recommendationId) async {
    try {
      await _aiService.markAsRead(recommendationId, _userId);
      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao marcar como lida', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Gera novas recomendações
  Future<bool> generateRecommendations() async {
    try {
      await _aiService.generateRecommendations(userId: _userId);
      await loadRecommendations();
      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao gerar recomendações', error: e, stackTrace: stack);
      return false;
    }
  }
}

/// Provider do StateNotifier
final recommendationsNotifierProvider =
    StateNotifierProvider<RecommendationsNotifier, AsyncValue<List<AIRecommendation>>>(
  (ref) {
    final aiService = ref.read(aiServiceProvider);
    final userId = SupabaseService.currentUser?.id ?? '';
    return RecommendationsNotifier(aiService, userId);
  },
);
