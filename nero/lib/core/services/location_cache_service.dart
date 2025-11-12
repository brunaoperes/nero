import 'dart:convert';
import 'package:hive/hive.dart';
import '../utils/app_logger.dart';
import '../errors/app_exceptions.dart';

/// Serviço de cache para buscas de localização
///
/// Armazena resultados de buscas para reduzir chamadas às APIs
/// e melhorar a performance do app
class LocationCacheService {
  static const String _boxName = 'location_search_cache';
  static const Duration _defaultTTL = Duration(hours: 24);

  // Cache em memória para acesso rápido
  static final Map<String, _CacheEntry> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50;

  /// Inicializa o cache
  static Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
        AppLogger.info('LocationCacheService initialized successfully');
      }
    } catch (e, stack) {
      AppLogger.error(
        'Failed to initialize LocationCacheService',
        error: e,
        stackTrace: stack,
      );
      throw StorageException(
        message: 'Erro ao inicializar cache de localizações',
        code: 'CACHE_INIT_ERROR',
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  /// Gera chave única para o cache baseada nos parâmetros de busca
  static String _generateCacheKey({
    required String query,
    required String source,
    double? latitude,
    double? longitude,
    int? radius,
  }) {
    final parts = [
      'q:$query',
      's:$source',
      if (latitude != null) 'lat:${latitude.toStringAsFixed(4)}',
      if (longitude != null) 'lng:${longitude.toStringAsFixed(4)}',
      if (radius != null) 'r:$radius',
    ];
    return parts.join('|').toLowerCase();
  }

  /// Busca resultados no cache
  ///
  /// Retorna null se não encontrado ou se expirado
  static Future<List<Map<String, dynamic>>?> get({
    required String query,
    required String source,
    double? latitude,
    double? longitude,
    int? radius,
    Duration? ttl,
  }) async {
    if (query.trim().isEmpty) return null;

    final cacheKey = _generateCacheKey(
      query: query,
      source: source,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    // 1. Verificar cache em memória primeiro
    if (_memoryCache.containsKey(cacheKey)) {
      final entry = _memoryCache[cacheKey]!;
      if (!entry.isExpired(ttl ?? _defaultTTL)) {
        AppLogger.debug('Cache hit (memory): $cacheKey');
        return entry.data;
      } else {
        _memoryCache.remove(cacheKey);
        AppLogger.debug('Cache expired (memory): $cacheKey');
      }
    }

    // 2. Verificar cache persistente (Hive)
    try {
      final box = Hive.box(_boxName);
      if (box.containsKey(cacheKey)) {
        final cached = box.get(cacheKey);
        if (cached != null) {
          final entry = _CacheEntry.fromMap(cached);

          if (!entry.isExpired(ttl ?? _defaultTTL)) {
            // Adicionar ao cache em memória para próximo acesso
            _addToMemoryCache(cacheKey, entry);

            AppLogger.debug('Cache hit (persistent): $cacheKey');
            return entry.data;
          } else {
            // Remover entrada expirada
            await box.delete(cacheKey);
            AppLogger.debug('Cache expired (persistent): $cacheKey');
          }
        }
      }
    } catch (e, stack) {
      AppLogger.warning(
        'Error reading from cache',
        error: e,
        stackTrace: stack,
      );
      // Continuar sem cache em caso de erro
    }

    AppLogger.debug('Cache miss: $cacheKey');
    return null;
  }

  /// Salva resultados no cache
  static Future<void> put({
    required String query,
    required String source,
    required List<Map<String, dynamic>> results,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    if (query.trim().isEmpty || results.isEmpty) return;

    final cacheKey = _generateCacheKey(
      query: query,
      source: source,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    final entry = _CacheEntry(
      data: results,
      timestamp: DateTime.now(),
    );

    // 1. Salvar no cache em memória
    _addToMemoryCache(cacheKey, entry);

    // 2. Salvar no cache persistente
    try {
      final box = Hive.box(_boxName);
      await box.put(cacheKey, entry.toMap());

      AppLogger.debug('Cached ${results.length} results for: $cacheKey');
    } catch (e, stack) {
      AppLogger.warning(
        'Error saving to cache',
        error: e,
        stackTrace: stack,
      );
      // Não lançar erro - cache é opcional
    }
  }

  /// Adiciona entrada ao cache em memória com limite de tamanho
  static void _addToMemoryCache(String key, _CacheEntry entry) {
    // Remover entrada mais antiga se atingir o limite
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      final oldestKey = _memoryCache.entries
          .reduce((a, b) =>
              a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _memoryCache.remove(oldestKey);
    }

    _memoryCache[key] = entry;
  }

  /// Limpa todo o cache
  static Future<void> clearAll() async {
    try {
      _memoryCache.clear();

      final box = Hive.box(_boxName);
      await box.clear();

      AppLogger.info('Location cache cleared');
    } catch (e, stack) {
      AppLogger.error(
        'Error clearing cache',
        error: e,
        stackTrace: stack,
      );
      throw StorageException(
        message: 'Erro ao limpar cache',
        code: 'CACHE_CLEAR_ERROR',
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  /// Remove entradas expiradas do cache
  static Future<void> cleanExpired({Duration? ttl}) async {
    try {
      final box = Hive.box(_boxName);
      final keysToDelete = <String>[];

      // Verificar entradas no cache persistente
      for (final key in box.keys) {
        final cached = box.get(key);
        if (cached != null) {
          final entry = _CacheEntry.fromMap(cached);
          if (entry.isExpired(ttl ?? _defaultTTL)) {
            keysToDelete.add(key.toString());
          }
        }
      }

      // Remover entradas expiradas
      for (final key in keysToDelete) {
        await box.delete(key);
      }

      // Limpar entradas expiradas da memória
      _memoryCache.removeWhere((key, entry) =>
          entry.isExpired(ttl ?? _defaultTTL));

      if (keysToDelete.isNotEmpty) {
        AppLogger.info('Cleaned ${keysToDelete.length} expired cache entries');
      }
    } catch (e, stack) {
      AppLogger.warning(
        'Error cleaning expired cache',
        error: e,
        stackTrace: stack,
      );
      // Não lançar erro - limpeza é opcional
    }
  }

  /// Retorna estatísticas do cache
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final box = Hive.box(_boxName);

      return {
        'memory_cache_size': _memoryCache.length,
        'persistent_cache_size': box.length,
        'max_memory_cache_size': _maxMemoryCacheSize,
        'default_ttl_hours': _defaultTTL.inHours,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}

/// Entrada do cache com timestamp
class _CacheEntry {
  final List<Map<String, dynamic>> data;
  final DateTime timestamp;

  _CacheEntry({
    required this.data,
    required this.timestamp,
  });

  /// Verifica se a entrada expirou
  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }

  /// Converte para Map para salvar no Hive
  Map<String, dynamic> toMap() {
    return {
      'data': jsonEncode(data),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Cria a partir de Map do Hive
  factory _CacheEntry.fromMap(Map<dynamic, dynamic> map) {
    return _CacheEntry(
      data: List<Map<String, dynamic>>.from(
        jsonDecode(map['data']).map((x) => Map<String, dynamic>.from(x)),
      ),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
