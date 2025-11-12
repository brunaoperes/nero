import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Modelo de perfil do usuário
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    /// ID do usuário (Supabase Auth)
    required String id,

    /// Email do usuário
    required String email,

    /// Nome completo
    String? fullName,

    /// Foto de perfil (URL ou caminho local)
    String? avatarUrl,

    /// Telefone
    String? phone,

    /// Data de nascimento
    DateTime? birthDate,

    /// CPF ou CNPJ (opcional)
    String? taxId,

    /// Biografia/Descrição
    String? bio,

    /// Data de criação da conta
    DateTime? createdAt,

    /// Última atualização
    DateTime? updatedAt,

    /// Estatísticas do usuário
    @Default(UserStats()) UserStats stats,

    /// Configurações do usuário
    @Default(UserSettings()) UserSettings settings,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Estatísticas do usuário
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    /// Total de tarefas criadas
    @Default(0) int totalTasks,

    /// Tarefas concluídas
    @Default(0) int completedTasks,

    /// Total de empresas
    @Default(0) int totalCompanies,

    /// Total de transações
    @Default(0) int totalTransactions,

    /// Saldo total
    @Default(0.0) double totalBalance,

    /// Dias desde o cadastro
    @Default(0) int daysActive,

    /// Sequência de dias ativos (streak)
    @Default(0) int dailyStreak,

    /// Conquistas desbloqueadas
    @Default([]) List<String> achievements,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

/// Configurações do usuário
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    // ===== APARÊNCIA =====
    /// Tema (dark/light/auto)
    @Default('auto') String theme,

    /// Cor primária customizada
    String? primaryColor,

    /// Tamanho da fonte (small/medium/large)
    @Default('medium') String fontSize,

    // ===== NOTIFICAÇÕES =====
    /// Push notifications habilitadas
    @Default(true) bool pushNotificationsEnabled,

    /// Email notifications habilitadas
    @Default(true) bool emailNotificationsEnabled,

    /// Lembrete de tarefas
    @Default(true) bool taskRemindersEnabled,

    /// Alertas financeiros
    @Default(true) bool financeAlertsEnabled,

    /// Horário dos lembretes diários
    @Default('09:00') String dailyReminderTime,

    // ===== IDIOMA =====
    /// Código do idioma (pt-BR, en-US, etc)
    @Default('pt-BR') String language,

    // ===== PRIVACIDADE =====
    /// Biometria habilitada
    @Default(false) bool biometricsEnabled,

    /// Backup automático
    @Default(true) bool autoBackupEnabled,

    /// Sincronização automática
    @Default(true) bool autoSyncEnabled,

    /// Dados de uso anônimos
    @Default(true) bool analyticsEnabled,

    // ===== OUTROS =====
    /// Mostrar tutorial
    @Default(true) bool showTutorial,

    /// Modo desenvolvedor
    @Default(false) bool developerMode,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

/// Extensões úteis para UserProfile
extension UserProfileX on UserProfile {
  /// Retorna as iniciais do nome
  String getInitials() {
    if (fullName == null || fullName!.isEmpty) {
      return email.substring(0, 1).toUpperCase();
    }

    final names = fullName!.split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }

    return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Retorna o primeiro nome
  String getFirstName() {
    if (fullName == null || fullName!.isEmpty) {
      return email.split('@')[0];
    }

    return fullName!.split(' ')[0];
  }

  /// Retorna a idade
  int? getAge() {
    if (birthDate == null) return null;

    final now = DateTime.now();
    int age = now.year - birthDate!.year;

    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }

    return age;
  }

  /// Verifica se o perfil está completo
  bool isProfileComplete() {
    return fullName != null &&
        fullName!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty &&
        birthDate != null;
  }

  /// Retorna a porcentagem de completude do perfil
  int getProfileCompleteness() {
    int completed = 0;
    const int total = 6;

    if (fullName != null && fullName!.isNotEmpty) completed++;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) completed++;
    if (phone != null && phone!.isNotEmpty) completed++;
    if (birthDate != null) completed++;
    if (taxId != null && taxId!.isNotEmpty) completed++;
    if (bio != null && bio!.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }
}

/// Extensões para UserStats
extension UserStatsX on UserStats {
  /// Taxa de conclusão de tarefas
  double getCompletionRate() {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks) * 100;
  }

  /// Verifica se tem conquistas
  bool hasAchievements() {
    return achievements.isNotEmpty;
  }

  /// Retorna o nível do usuário baseado nas tarefas concluídas
  int getLevel() {
    // Cada 10 tarefas concluídas = 1 nível
    return (completedTasks / 10).floor() + 1;
  }

  /// Progresso para o próximo nível
  int getLevelProgress() {
    return completedTasks % 10;
  }
}

/// Conquistas disponíveis
enum Achievement {
  firstTask('first_task', '🎯', 'Primeira Tarefa', 'Criou sua primeira tarefa'),
  taskMaster('task_master', '⭐', 'Mestre das Tarefas', 'Completou 100 tarefas'),
  earlyBird('early_bird', '🌅', 'Madrugador', 'Completou tarefas antes das 8h'),
  nightOwl('night_owl', '🦉', 'Noturno', 'Completou tarefas depois das 22h'),
  weekStreak('week_streak', '🔥', 'Semana Completa', '7 dias de sequência'),
  monthStreak('month_streak', '💎', 'Mês Completo', '30 dias de sequência'),
  savvy('savvy', '💰', 'Econômico', 'Economia positiva por 3 meses'),
  organized('organized', '📊', 'Organizado', 'Usou todas as features'),
  social('social', '🤝', 'Social', 'Compartilhou 10 relatórios'),
  perfectWeek('perfect_week', '✨', 'Semana Perfeita', '100% das tarefas concluídas');

  final String id;
  final String icon;
  final String title;
  final String description;

  const Achievement(this.id, this.icon, this.title, this.description);

  static Achievement? fromId(String id) {
    try {
      return Achievement.values.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
