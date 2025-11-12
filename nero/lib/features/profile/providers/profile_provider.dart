import 'dart:io';
import 'package:nero/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/models/user_profile.dart';

/// Provider para o perfil do usuário
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return UserProfileNotifier();
});

/// Notifier para gerenciar o perfil do usuário
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  /// Carrega o perfil do usuário
  Future<void> _loadProfile() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        state = AsyncValue.error('Usuário não autenticado', StackTrace.current);
        return;
      }

      // Buscar perfil do Supabase
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        // Perfil existe - calcular estatísticas em tempo real
        final stats = await _calculateStats(user.id);

        final profile = UserProfile.fromJson({
          ...response,
          'email': user.email!,
          'stats': stats.toJson(),
        });

        state = AsyncValue.data(profile);
      } else {
        // Criar perfil inicial
        final stats = await _calculateStats(user.id);
        final newProfile = UserProfile(
          id: user.id,
          email: user.email!,
          stats: stats,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await SupabaseService.client.from('profiles').insert({
          'id': newProfile.id,
          'full_name': newProfile.fullName,
          'avatar_url': newProfile.avatarUrl,
          'phone': newProfile.phone,
          'birth_date': newProfile.birthDate?.toIso8601String(),
          'tax_id': newProfile.taxId,
          'bio': newProfile.bio,
          'stats': newProfile.stats.toJson(),
          'created_at': newProfile.createdAt?.toIso8601String(),
          'updated_at': newProfile.updatedAt?.toIso8601String(),
        });

        state = AsyncValue.data(newProfile);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Calcula as estatísticas reais do usuário baseado nos dados do banco
  Future<UserStats> _calculateStats(String userId) async {
    try {
      // Buscar contagem de empresas
      final companiesData = await SupabaseService.client
          .from('companies')
          .select()
          .eq('user_id', userId);
      final companiesCount = companiesData.length;

      // Buscar contagem de tarefas
      final tasksData = await SupabaseService.client
          .from('tasks')
          .select()
          .eq('user_id', userId);
      final tasksCount = tasksData.length;

      // Buscar contagem de tarefas concluídas
      final completedTasksData = await SupabaseService.client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', true);
      final completedTasksCount = completedTasksData.length;

      // Buscar contagem de transações
      final transactionsCountData = await SupabaseService.client
          .from('transactions')
          .select()
          .eq('user_id', userId);
      final transactionsCount = transactionsCountData.length;

      // Buscar saldo total (soma de receitas - despesas)
      final transactionsData = await SupabaseService.client
          .from('transactions')
          .select('amount, type')
          .eq('user_id', userId);

      double totalBalance = 0.0;
      for (final transaction in transactionsData) {
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
        final type = transaction['type'] as String?;

        if (type == 'income') {
          totalBalance += amount;
        } else if (type == 'expense') {
          totalBalance -= amount;
        }
      }

      // Calcular dias ativos (pode ser melhorado com lógica mais sofisticada)
      final profileData = await SupabaseService.client
          .from('profiles')
          .select('created_at')
          .eq('id', userId)
          .maybeSingle();

      int daysActive = 0;
      if (profileData != null && profileData['created_at'] != null) {
        final createdAt = DateTime.parse(profileData['created_at'] as String);
        daysActive = DateTime.now().difference(createdAt).inDays;
      }

      // TODO: Implementar lógica de daily streak (requer histórico de atividades)
      const dailyStreak = 0;

      // TODO: Carregar conquistas do banco ou calcular
      final achievements = <String>[];

      return UserStats(
        totalTasks: tasksCount,
        completedTasks: completedTasksCount,
        totalCompanies: companiesCount,
        totalTransactions: transactionsCount,
        totalBalance: totalBalance,
        daysActive: daysActive,
        dailyStreak: dailyStreak,
        achievements: achievements,
      );
    } catch (e) {
      // Em caso de erro, retornar stats zerados
      AppLogger.error('Erro ao calcular estatísticas', error: e);
      return const UserStats();
    }
  }

  /// Atualiza o perfil
  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      state = const AsyncValue.loading();

      await SupabaseService.client.from('profiles').update({
        'full_name': updatedProfile.fullName,
        'phone': updatedProfile.phone,
        'birth_date': updatedProfile.birthDate?.toIso8601String(),
        'tax_id': updatedProfile.taxId,
        'bio': updatedProfile.bio,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', updatedProfile.id);

      state = AsyncValue.data(updatedProfile.copyWith(
        updatedAt: DateTime.now(),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Atualiza o avatar
  Future<void> updateAvatar(File imageFile) async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      state = const AsyncValue.loading();

      // Upload da imagem para Supabase Storage
      final fileName = '${currentProfile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'avatars/$fileName';

      await SupabaseService.client.storage
          .from('profiles')
          .upload(path, imageFile);

      // Obter URL pública
      final avatarUrl = SupabaseService.client.storage
          .from('profiles')
          .getPublicUrl(path);

      // Atualizar perfil
      await SupabaseService.client.from('profiles').update({
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentProfile.id);

      state = AsyncValue.data(currentProfile.copyWith(
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Remove o avatar
  Future<void> removeAvatar() async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      state = const AsyncValue.loading();

      // Se tem avatar URL, deletar do storage
      if (currentProfile.avatarUrl != null) {
        try {
          final path = currentProfile.avatarUrl!.split('/').last;
          await SupabaseService.client.storage
              .from('profiles')
              .remove(['avatars/$path']);
        } catch (_) {
          // Ignorar erro ao deletar do storage
        }
      }

      // Atualizar perfil
      await SupabaseService.client.from('profiles').update({
        'avatar_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentProfile.id);

      state = AsyncValue.data(currentProfile.copyWith(
        avatarUrl: null,
        updatedAt: DateTime.now(),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Atualiza as configurações
  Future<void> updateSettings(UserSettings settings) async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      state = const AsyncValue.loading();

      // Salvar settings no Supabase (como JSON)
      await SupabaseService.client.from('profiles').update({
        'settings': settings.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentProfile.id);

      state = AsyncValue.data(currentProfile.copyWith(
        settings: settings,
        updatedAt: DateTime.now(),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Atualiza as estatísticas
  Future<void> updateStats(UserStats stats) async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      state = const AsyncValue.loading();

      // Salvar stats no Supabase (como JSON)
      await SupabaseService.client.from('profiles').update({
        'stats': stats.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentProfile.id);

      state = AsyncValue.data(currentProfile.copyWith(
        stats: stats,
        updatedAt: DateTime.now(),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Adiciona uma conquista
  Future<void> unlockAchievement(Achievement achievement) async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      // Verificar se já tem a conquista
      if (currentProfile.stats.achievements.contains(achievement.id)) {
        return;
      }

      final updatedAchievements = [
        ...currentProfile.stats.achievements,
        achievement.id,
      ];

      final updatedStats = currentProfile.stats.copyWith(
        achievements: updatedAchievements,
      );

      await updateStats(updatedStats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Recarrega o perfil
  Future<void> reload() async {
    await _loadProfile();
  }
}

/// Provider para seleção de imagem
final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

/// Provider para ações de perfil
final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});

/// Classe com ações de perfil
class ProfileActions {
  final Ref _ref;

  ProfileActions(this._ref);

  /// Seleciona uma foto da galeria
  Future<File?> pickImageFromGallery() async {
    try {
      final picker = _ref.read(imagePickerProvider);
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Tira uma foto com a câmera
  Future<File?> pickImageFromCamera() async {
    try {
      final picker = _ref.read(imagePickerProvider);
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Atualiza a senha
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      // Validar senha atual
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      // Tentar reautenticar com senha atual
      try {
        await SupabaseService.client.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
      } catch (_) {
        throw Exception('Senha atual incorreta');
      }

      // Atualizar senha
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return true;
    } catch (e) {
      throw Exception('Erro ao atualizar senha: $e');
    }
  }

  /// Atualiza o email
  Future<bool> updateEmail(String newEmail) async {
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      return true;
    } catch (e) {
      throw Exception('Erro ao atualizar email: $e');
    }
  }

  /// Deleta a conta
  Future<bool> deleteAccount() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      // Deletar perfil
      await SupabaseService.client
          .from('profiles')
          .delete()
          .eq('id', user.id);

      // Deletar conta do Auth
      // Nota: Supabase não tem endpoint direto para deletar conta via client
      // Isso geralmente é feito via função RPC ou admin API
      // Por enquanto, vamos só fazer logout

      await SupabaseService.signOut();

      return true;
    } catch (e) {
      throw Exception('Erro ao deletar conta: $e');
    }
  }
}
