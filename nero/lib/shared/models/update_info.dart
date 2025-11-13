/// Modelo para informações de atualização do app
class UpdateInfo {
  final String versionName;
  final int versionCode;
  final int minVersionCode;
  final bool mandatory;
  final String apkUrl;
  final String apkSha256;
  final List<String> changelog;

  UpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.minVersionCode,
    required this.mandatory,
    required this.apkUrl,
    required this.apkSha256,
    required this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      versionName: json['versionName'] as String,
      versionCode: json['versionCode'] as int,
      minVersionCode: json['minVersionCode'] as int,
      mandatory: json['mandatory'] as bool,
      apkUrl: json['apkUrl'] as String,
      apkSha256: json['apkSha256'] as String,
      changelog: (json['changelog'] as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionName': versionName,
      'versionCode': versionCode,
      'minVersionCode': minVersionCode,
      'mandatory': mandatory,
      'apkUrl': apkUrl,
      'apkSha256': apkSha256,
      'changelog': changelog,
    };
  }

  /// Verifica se há atualização disponível comparando com a versão atual
  bool hasUpdate(int currentVersionCode) {
    return versionCode > currentVersionCode;
  }

  /// Verifica se a atualização é obrigatória
  bool isMandatoryFor(int currentVersionCode) {
    return currentVersionCode < minVersionCode;
  }

  @override
  String toString() {
    return 'UpdateInfo{versionName: $versionName, versionCode: $versionCode, mandatory: $mandatory}';
  }
}

/// Enumeração para status do download
enum DownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  failed,
  verifying,
  installing,
}

/// Modelo para progresso do download
class DownloadProgress {
  final DownloadStatus status;
  final int bytesReceived;
  final int totalBytes;
  final String? error;

  DownloadProgress({
    required this.status,
    this.bytesReceived = 0,
    this.totalBytes = 0,
    this.error,
  });

  double get progress {
    if (totalBytes == 0) return 0.0;
    return bytesReceived / totalBytes;
  }

  double get progressPercentage => progress * 100;

  String get speedText {
    if (totalBytes == 0) return '0 KB/s';
    // Implementação simplificada - pode ser melhorada com cálculo real de velocidade
    return '-- KB/s';
  }

  DownloadProgress copyWith({
    DownloadStatus? status,
    int? bytesReceived,
    int? totalBytes,
    String? error,
  }) {
    return DownloadProgress(
      status: status ?? this.status,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'DownloadProgress{status: $status, progress: ${progressPercentage.toStringAsFixed(1)}%}';
  }
}
