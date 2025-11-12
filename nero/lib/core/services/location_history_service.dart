import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nero/core/errors/app_exceptions.dart';
import 'package:nero/core/utils/app_logger.dart';

/// Serviço de histórico inteligente de localizações
///
/// Salva locais escolhidos pelo usuário e aprende com os padrões de uso.
/// Funciona de forma similar ao histórico do iPhone Calendar.
class LocationHistoryService {
  static const String _boxName = 'location_history';
  static const int _maxHistoryItems = 50; // Máximo de locais salvos

  /// Modelo de dados para histórico de localização
  static const String _keyLocations = 'locations';

  /// Inicializa o Hive box para histórico
  static Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
        AppLogger.info('LocationHistoryService initialized successfully');
      }
    } catch (e, stack) {
      AppLogger.error(
        'Failed to initialize LocationHistoryService',
        error: e,
        stackTrace: stack,
      );
      throw StorageException(
        message: 'Erro ao inicializar histórico de localizações',
        code: 'INIT_ERROR',
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  /// Salva uma localização no histórico quando o usuário a escolhe
  Future<void> saveLocationToHistory({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? category,
    String? source,
  }) async {
    try {
      final box = Hive.box(_boxName);

      // Obter histórico atual
      List<Map<String, dynamic>> history = _getHistoryList();

      // Criar novo item
      final newItem = {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'source': source,
        'lastUsed': DateTime.now().toIso8601String(),
        'useCount': 1,
      };

      // Verificar se já existe (mesmo nome OU coordenadas próximas)
      final existingIndex = history.indexWhere((item) {
        // Mesmo nome exato
        if (item['name'] == name) return true;

        // Coordenadas muito próximas (raio de ~10 metros)
        final lat = item['latitude'] as double;
        final lng = item['longitude'] as double;
        final distance = _calculateDistance(lat, lng, latitude, longitude);
        return distance < 0.01; // ~10 metros
      });

      if (existingIndex != -1) {
        // Atualizar item existente (incrementar contador e data)
        final existing = history[existingIndex];
        existing['lastUsed'] = DateTime.now().toIso8601String();
        existing['useCount'] = (existing['useCount'] ?? 0) + 1;

        // Mover para o topo (mais recente)
        history.removeAt(existingIndex);
        history.insert(0, existing);
      } else {
        // Adicionar novo item no topo
        history.insert(0, newItem);

        // Limitar tamanho do histórico
        if (history.length > _maxHistoryItems) {
          history = history.sublist(0, _maxHistoryItems);
        }
      }

      // Salvar no Hive
      await box.put(_keyLocations, history);

      AppLogger.debug('Location saved to history: $name');
    } catch (e, stack) {
      AppLogger.error(
        'Failed to save location to history',
        error: e,
        stackTrace: stack,
        data: {'name': name, 'address': address},
      );
      throw StorageException.writeError('location_history');
    }
  }

  /// Obtém sugestões inteligentes baseadas no histórico
  ///
  /// Retorna locais ordenados por:
  /// 1. Relevância com a query (se fornecida)
  /// 2. Frequência de uso (useCount)
  /// 3. Recência (lastUsed)
  List<Map<String, dynamic>> getSmartSuggestions({
    String? query,
    int limit = 5,
  }) {
    try {
      List<Map<String, dynamic>> history = _getHistoryList();

      if (history.isEmpty) return [];

      // Se tem query, filtrar por relevância
      if (query != null && query.trim().isNotEmpty) {
        final queryLower = query.toLowerCase().trim();

        // Calcular score de relevância para cada item
        final scoredItems = history.map((item) {
          final name = (item['name'] as String).toLowerCase();
          final address = (item['address'] as String).toLowerCase();

          double score = 0.0;

          // Match exato no nome = score alto
          if (name == queryLower) {
            score += 100.0;
          } else if (name.startsWith(queryLower)) {
            score += 50.0;
          } else if (name.contains(queryLower)) {
            score += 25.0;
          }

          // Match no endereço = score menor
          if (address.contains(queryLower)) {
            score += 10.0;
          }

          // Boost por frequência de uso
          final useCount = item['useCount'] ?? 1;
          score += useCount * 2.0;

          // Boost por recência (até 7 dias)
          final lastUsed = DateTime.parse(item['lastUsed'] as String);
          final daysSinceUse = DateTime.now().difference(lastUsed).inDays;
          if (daysSinceUse <= 7) {
            score += (7 - daysSinceUse) * 1.0;
          }

          return {'item': item, 'score': score};
        }).toList();

        // Ordenar por score (maior primeiro)
        scoredItems.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

        // Retornar apenas os itens (sem score)
        return scoredItems
            .where((scored) => (scored['score'] as double) > 0)
            .take(limit)
            .map((scored) => scored['item'] as Map<String, dynamic>)
            .toList();
      }

      // Sem query: retornar mais usados e mais recentes
      final sorted = List<Map<String, dynamic>>.from(history);
      sorted.sort((a, b) {
        // Primeiro: por frequência de uso
        final useCountA = a['useCount'] ?? 1;
        final useCountB = b['useCount'] ?? 1;
        if (useCountA != useCountB) {
          return useCountB.compareTo(useCountA);
        }

        // Segundo: por recência
        final lastUsedA = DateTime.parse(a['lastUsed'] as String);
        final lastUsedB = DateTime.parse(b['lastUsed'] as String);
        return lastUsedB.compareTo(lastUsedA);
      });

      return sorted.take(limit).toList();
    } catch (e, stack) {
      AppLogger.error(
        'Failed to get smart suggestions',
        error: e,
        stackTrace: stack,
        data: {'query': query, 'limit': limit},
      );
      return []; // Retornar lista vazia em caso de erro (graceful degradation)
    }
  }

  /// Obtém todos os locais do histórico (ordenados por mais recente)
  List<Map<String, dynamic>> getAllHistory() {
    return _getHistoryList();
  }

  /// Remove um local do histórico
  Future<void> removeFromHistory(String name) async {
    try {
      final box = Hive.box(_boxName);
      List<Map<String, dynamic>> history = _getHistoryList();

      history.removeWhere((item) => item['name'] == name);

      await box.put(_keyLocations, history);

      AppLogger.debug('Location removed from history: $name');
    } catch (e, stack) {
      AppLogger.error(
        'Failed to remove location from history',
        error: e,
        stackTrace: stack,
        data: {'name': name},
      );
      throw StorageException.deleteError('location_history');
    }
  }

  /// Limpa todo o histórico
  Future<void> clearHistory() async {
    try {
      final box = Hive.box(_boxName);
      await box.delete(_keyLocations);

      AppLogger.info('Location history cleared');
    } catch (e, stack) {
      AppLogger.error(
        'Failed to clear location history',
        error: e,
        stackTrace: stack,
      );
      throw StorageException.deleteError('location_history');
    }
  }

  /// Obtém a lista de histórico do Hive
  List<Map<String, dynamic>> _getHistoryList() {
    try {
      final box = Hive.box(_boxName);
      final data = box.get(_keyLocations);

      if (data == null) return [];

      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      return [];
    } catch (e) {
      AppLogger.warning(
        'Failed to read location history',
        data: {'error': e.toString()},
      );
      return []; // Retornar lista vazia em caso de erro
    }
  }

  /// Calcula distância aproximada entre duas coordenadas (em graus)
  /// Não é preciso, mas suficiente para detectar duplicatas
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    final dLat = (lat1 - lat2).abs();
    final dLng = (lng1 - lng2).abs();
    return dLat + dLng; // Distância Manhattan (simplificado)
  }
}

/// Provider do serviço de histórico de localizações
final locationHistoryServiceProvider = Provider<LocationHistoryService>((ref) {
  return LocationHistoryService();
});
