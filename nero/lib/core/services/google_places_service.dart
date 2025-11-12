import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/google_places_config.dart';
import '../utils/app_logger.dart';
import 'location_cache_service.dart';

/// Serviço de busca PREMIUM usando Google Places API
///
/// 🎯 Tier Gratuito: $200/mês (~70.000 requisições)
/// ✅ Melhor qualidade de resultados
/// ✅ Autocomplete inteligente
/// ✅ Fallback automático quando exceder limite
/// ✅ Tracking de uso para controle de custos
class GooglePlacesService {
  GooglePlacesService._();

  /// Verifica se podemos usar Google Places (dentro do limite de segurança)
  static Future<bool> canUseGooglePlaces() async {
    // Google Places API não funciona no web devido a CORS
    // Use apenas em mobile (Android/iOS)
    if (kIsWeb) {
      AppLogger.info('Google Places desabilitado no web (CORS). Usando fallback');
      return false;
    }

    if (!GooglePlacesConfig.isConfigured) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentMonth = DateTime.now().month;
    final savedMonth = prefs.getInt(GooglePlacesConfig.requestMonthKey) ?? 0;

    // Reset contador se mudou de mês
    if (currentMonth != savedMonth) {
      await prefs.setInt(GooglePlacesConfig.requestCountKey, 0);
      await prefs.setInt(GooglePlacesConfig.requestMonthKey, currentMonth);
      return true;
    }

    final count = prefs.getInt(GooglePlacesConfig.requestCountKey) ?? 0;
    final canUse = count < GooglePlacesConfig.safetyLimitRequests;

    // Alerta se aproximando do limite
    if (count >= GooglePlacesConfig.safetyLimitRequests * 0.9) {
      AppLogger.warning('Google Places aproximando do limite', data: {
        'usagePercentage': _getUsagePercentage(count),
        'currentCount': count,
        'limit': GooglePlacesConfig.safetyLimitRequests,
      });
    }

    return canUse;
  }

  /// Retorna percentual de uso do limite mensal
  static Future<double> getUsagePercentage() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(GooglePlacesConfig.requestCountKey) ?? 0;
    return _getUsagePercentage(count);
  }

  static double _getUsagePercentage(int count) {
    return (count / GooglePlacesConfig.safetyLimitRequests) * 100;
  }

  /// Retorna estatísticas de uso
  static Future<Map<String, dynamic>> getUsageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(GooglePlacesConfig.requestCountKey) ?? 0;
    final month = prefs.getInt(GooglePlacesConfig.requestMonthKey) ?? 0;

    final cost = count * GooglePlacesConfig.costPerRequest;
    final remaining = GooglePlacesConfig.safetyLimitRequests - count;

    return {
      'count': count,
      'month': month,
      'cost': cost,
      'remaining': remaining,
      'percentage': _getUsagePercentage(count),
      'canUse': count < GooglePlacesConfig.safetyLimitRequests,
    };
  }

  /// Incrementa contador de requisições
  static Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(GooglePlacesConfig.requestCountKey) ?? 0;
    await prefs.setInt(GooglePlacesConfig.requestCountKey, count + 1);

    final newCount = count + 1;
    if (newCount % 1000 == 0) {
      AppLogger.info('Google Places milestone', data: {
        'requestsThisMonth': newCount,
        'limit': GooglePlacesConfig.safetyLimitRequests,
      });
    }
  }

  /// Busca lugares usando Google Places Autocomplete
  ///
  /// Parâmetros:
  /// - [query]: Texto de busca
  /// - [location]: Localização de referência (lat,lng)
  /// - [radius]: Raio de busca em metros
  ///
  /// Retorna lista vazia se exceder limite (ativa fallback)
  static Future<List<GooglePlace>> searchPlaces({
    required String query,
    String? location,
    int radius = 50000,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // 1. Verificar cache primeiro
    try {
      double? lat, lng;
      if (location != null && location.isNotEmpty) {
        final parts = location.split(',');
        if (parts.length == 2) {
          lat = double.tryParse(parts[0]);
          lng = double.tryParse(parts[1]);
        }
      }

      final cached = await LocationCacheService.get(
        query: query,
        source: 'google_places',
        latitude: lat,
        longitude: lng,
        radius: radius,
      );

      if (cached != null) {
        return cached
            .map((json) => GooglePlace.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Continuar sem cache em caso de erro
      AppLogger.warning('Erro ao buscar cache Google Places', error: e);
    }

    // 2. Verificar se pode usar Google Places
    if (!await canUseGooglePlaces()) {
      AppLogger.info('Google Places limite atingido, usando fallback');
      return [];
    }

    // 3. Buscar na API
    try {
      final queryParams = {
        'input': query,
        'language': GooglePlacesConfig.defaultLanguage,
        'components': 'country:${GooglePlacesConfig.defaultCountryCode}',
        'key': GooglePlacesConfig.GOOGLE_PLACES_API_KEY,
      };

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
        queryParams['radius'] = radius.toString();
      }

      final uri = Uri.parse(GooglePlacesConfig.autocompleteUrl)
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Incrementar contador APENAS se sucesso
        await _incrementCounter();

        final data = json.decode(response.body);
        final status = data['status'] as String?;

        if (status == 'OK') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          final places = predictions
              .map((pred) => GooglePlace.fromJson(pred))
              .toList();

          // 4. Salvar no cache
          if (places.isNotEmpty) {
            try {
              double? lat, lng;
              if (location != null && location.isNotEmpty) {
                final parts = location.split(',');
                if (parts.length == 2) {
                  lat = double.tryParse(parts[0]);
                  lng = double.tryParse(parts[1]);
                }
              }

              await LocationCacheService.put(
                query: query,
                source: 'google_places',
                results: predictions.cast<Map<String, dynamic>>(),
                latitude: lat,
                longitude: lng,
                radius: radius,
              );
            } catch (e) {
              // Não falhar se cache não funcionar
              AppLogger.warning('Erro ao salvar cache Google Places', error: e);
            }
          }

          return places;
        } else if (status == 'ZERO_RESULTS') {
          return [];
        } else {
          AppLogger.warning('Google Places status não esperado', data: {'status': status});
          return [];
        }
      } else if (response.statusCode == 401) {
        AppLogger.error('Google Places: API Key inválida');
        return [];
      } else if (response.statusCode == 429) {
        AppLogger.error('Google Places: Limite de requisições excedido');
        return [];
      } else {
        AppLogger.error('Google Places erro HTTP', data: {'statusCode': response.statusCode});
        return [];
      }
    } catch (e, stack) {
      AppLogger.error('Google Places falhou', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Busca detalhes de um lugar específico (place_id)
  ///
  /// Usado para obter coordenadas após seleção do autocomplete
  static Future<GooglePlaceDetails?> getPlaceDetails({
    required String placeId,
  }) async {
    if (!await canUseGooglePlaces()) {
      return null;
    }

    try {
      final queryParams = {
        'place_id': placeId,
        'fields': 'name,formatted_address,geometry,types',
        'language': GooglePlacesConfig.defaultLanguage,
        'key': GooglePlacesConfig.GOOGLE_PLACES_API_KEY,
      };

      final uri = Uri.parse(GooglePlacesConfig.detailsUrl)
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        await _incrementCounter();

        final data = json.decode(response.body);
        final status = data['status'] as String?;

        if (status == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          return GooglePlaceDetails.fromJson(result);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e, stack) {
      AppLogger.error('Google Places details falhou', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Reset manual do contador (para testes)
  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(GooglePlacesConfig.requestCountKey, 0);
    await prefs.setInt(GooglePlacesConfig.requestMonthKey, DateTime.now().month);
    AppLogger.info('Contador Google Places resetado');
  }
}

/// Modelo de dados para um resultado de autocomplete do Google Places
class GooglePlace {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  GooglePlace({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  factory GooglePlace.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};

    final typesList = json['types'] as List<dynamic>? ?? [];
    final types = typesList.map((t) => t.toString()).toList();

    return GooglePlace(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: structuredFormatting['main_text'] as String? ?? '',
      secondaryText: structuredFormatting['secondary_text'] as String? ?? '',
      types: types,
    );
  }

  /// Retorna o nome principal
  String get primaryText => mainText.isNotEmpty ? mainText : description;

  /// Retorna o endereço
  String get fullAddress => description;

  /// Verifica se é um estabelecimento comercial
  bool get isEstablishment {
    return types.any((type) => [
          'establishment',
          'point_of_interest',
          'store',
          'restaurant',
          'cafe',
          'bar',
          'lodging',
        ].contains(type));
  }

  @override
  String toString() => description;
}

/// Modelo de dados para detalhes completos de um lugar
class GooglePlaceDetails {
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final List<String> types;

  GooglePlaceDetails({
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.types,
  });

  factory GooglePlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};

    final typesList = json['types'] as List<dynamic>? ?? [];
    final types = typesList.map((t) => t.toString()).toList();

    return GooglePlaceDetails(
      name: json['name'] as String? ?? '',
      formattedAddress: json['formatted_address'] as String? ?? '',
      latitude: location['lat'] as double? ?? 0.0,
      longitude: location['lng'] as double? ?? 0.0,
      types: types,
    );
  }
}
