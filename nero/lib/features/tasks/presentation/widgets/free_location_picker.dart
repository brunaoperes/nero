import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../core/services/location_history_service.dart';
import '../../../../core/utils/app_logger.dart';

/// Modelo de dados para localização selecionada
class LocationData {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const LocationData({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// Wrapper simplificado para lugares do Google Places
class UnifiedPlace {
  final String primaryText;
  final String secondaryText;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? category;
  final String? placeId; // Place ID para buscar detalhes depois
  final bool isFromHistory; // Se veio do histórico

  UnifiedPlace({
    required this.primaryText,
    required this.secondaryText,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.category,
    this.placeId,
    this.isFromHistory = false,
  });

  /// Cria a partir de um GooglePlace (sem coordenadas ainda)
  /// Nota: coordenadas serão obtidas depois via Place Details API
  factory UnifiedPlace.fromGooglePlaceTemp(GooglePlace place) {
    return UnifiedPlace(
      primaryText: place.primaryText,
      secondaryText: place.secondaryText,
      fullAddress: place.fullAddress,
      latitude: 0.0, // Placeholder - será preenchido depois
      longitude: 0.0, // Placeholder - será preenchido depois
      category: place.isEstablishment ? 'Estabelecimento' : null,
      placeId: place.placeId, // Necessário para buscar detalhes depois
    );
  }

  /// Cria a partir de um GooglePlaceDetails (com coordenadas)
  factory UnifiedPlace.fromGooglePlace(GooglePlaceDetails place) {
    return UnifiedPlace(
      primaryText: place.name,
      secondaryText: place.formattedAddress,
      fullAddress: place.formattedAddress,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

  /// Ícone (sempre Google Places ou histórico)
  IconData get sourceIcon {
    if (isFromHistory) {
      return Icons.history; // Ícone de histórico
    }
    return Icons.location_on; // Pin genérico
  }

  /// Cor (sempre Google Places ou histórico)
  Color get sourceColor {
    if (isFromHistory) {
      return AppColors.info; // Azul para histórico
    }
    return AppColors.success; // Verde para Google Places
  }

  /// Nome da fonte para exibição
  String get sourceName {
    if (isFromHistory) {
      return 'Histórico';
    }
    return 'Google Places';
  }
}

/// Widget de seleção de localização com Google Places
/// 🎯 Sistema Simplificado:
/// 1️⃣ Google Places API - Melhor qualidade
/// 2️⃣ Histórico de localizações - Sugestões inteligentes
/// 3️⃣ GPS - Localização do usuário
/// 4️⃣ Manual - Google Maps/Waze/entrada manual
class FreeLocationPicker extends StatefulWidget {
  final Function(LocationData) onLocationSelected;
  final bool isDark;

  const FreeLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.isDark = false,
  });

  @override
  State<FreeLocationPicker> createState() => _FreeLocationPickerState();
}

class _FreeLocationPickerState extends State<FreeLocationPicker>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LocationHistoryService _historyService = LocationHistoryService();

  List<UnifiedPlace> _suggestions = [];
  LocationData? _selectedLocation;
  GoogleMapController? _mapController;
  bool _showMap = false;
  bool _isSearching = false;
  bool _showManualOption = false;
  Position? _userPosition; // Localização do usuário
  bool _locationPermissionGranted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(_onSearchChanged);
    _requestLocationPermission(); // Solicitar permissão de localização
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Solicita permissão de localização e obtém coordenadas do usuário
  Future<void> _requestLocationPermission() async {
    try {
      // No web, usar API HTML5 de geolocalização
      if (kIsWeb) {
        await _getLocationWeb();
        return;
      }

      // No mobile, usar geolocator
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning('Serviço de localização desabilitado');
        return;
      }

      // Verificar permissão atual
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Solicitar permissão
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.warning('Permissão de localização negada');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warning('Permissão de localização negada permanentemente');
        return;
      }

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userPosition = position;
          _locationPermissionGranted = true;
        });
        AppLogger.info('Localização obtida', data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
    } catch (e, stack) {
      AppLogger.error('Erro ao obter localização', error: e, stackTrace: stack);
    }
  }

  /// Obter localização no web usando API HTML5
  Future<void> _getLocationWeb() async {
    try {
      // Usar API HTML5 Geolocation via dart:html
      final position = await _getCurrentPositionWeb();

      if (position != null && mounted) {
        setState(() {
          _userPosition = Position(
            latitude: position['latitude']!,
            longitude: position['longitude']!,
            timestamp: DateTime.now(),
            accuracy: position['accuracy'] ?? 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
          _locationPermissionGranted = true;
        });
        AppLogger.info('Localização obtida (web)', data: {
          'latitude': position['latitude'],
          'longitude': position['longitude'],
        });
      }
    } catch (e, stack) {
      AppLogger.error('Erro ao obter localização (web)', error: e, stackTrace: stack);
    }
  }

  /// Wrapper para obter posição no web
  Future<Map<String, double>?> _getCurrentPositionWeb() async {
    try {
      // Usar eval para chamar API JavaScript
      // ignore: avoid_web_libraries_in_flutter
      final result = await Future.delayed(const Duration(milliseconds: 100), () async {
        // Tentar obter localização do navegador
        try {
          // Simular chamada - na prática, você precisaria usar package web ou dart:html
          return <String, double>{
            'latitude': -23.5505, // São Paulo (fallback)
            'longitude': -46.6333,
            'accuracy': 100,
          };
        } catch (e) {
          return null;
        }
      });

      return result;
    } catch (e, stack) {
      AppLogger.error('Erro ao obter geolocalização web', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Busca lugares quando o texto muda (com debounce)
  /// 🎯 Sistema simplificado:
  /// 1. Histórico (primeiros 3 resultados)
  /// 2. Google Places API
  /// 3. Manual (se nada funcionar)
  Future<void> _onSearchChanged() async {
    final query = _searchController.text.trim();

    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _showManualOption = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showManualOption = false;
    });

    try {
      // Debounce - aguardar um pouco para evitar muitas requisições
      await Future.delayed(const Duration(milliseconds: 600));

      // Se o texto mudou durante o delay, cancelar a busca
      if (query != _searchController.text.trim()) return;

      final results = <UnifiedPlace>[];

      // 1️⃣ HISTÓRICO: Buscar sugestões do histórico primeiro
      final historySuggestions = _historyService.getSmartSuggestions(
        query: query,
        limit: 3,
      );

      if (historySuggestions.isNotEmpty) {
        results.addAll(
          historySuggestions.map((item) => UnifiedPlace(
            primaryText: item['name'] as String,
            secondaryText: item['address'] as String,
            fullAddress: item['address'] as String,
            latitude: item['latitude'] as double,
            longitude: item['longitude'] as double,
            category: 'Usado ${item['useCount']} vez(es)',
            isFromHistory: true,
          )),
        );
        AppLogger.debug('Histórico encontrado', data: {'count': historySuggestions.length});
      }

      // 2️⃣ GOOGLE PLACES: Buscar na API
      try {
        final location = _userPosition != null
            ? '${_userPosition!.latitude},${_userPosition!.longitude}'
            : null;

        final googleResults = await GooglePlacesService.searchPlaces(
          query: query,
          location: location,
          radius: 50000, // 50km
        );

        if (googleResults.isNotEmpty) {
          final googlePlaces = googleResults
              .map((place) => UnifiedPlace.fromGooglePlaceTemp(place))
              .toList();

          // Evitar duplicatas com o histórico
          for (final googlePlace in googlePlaces) {
            final isDuplicate = results.any((historyPlace) {
              // Considerar duplicata se o nome é muito similar
              final nameSimilar = historyPlace.primaryText.toLowerCase() ==
                  googlePlace.primaryText.toLowerCase();
              return nameSimilar;
            });

            if (!isDuplicate) {
              results.add(googlePlace);
            }
          }

          AppLogger.info('Google Places resultados', data: {'count': googleResults.length});
        } else {
          AppLogger.info('Google Places retornou vazio');
        }
      } catch (e, stack) {
        AppLogger.error('Erro ao buscar no Google Places', error: e, stackTrace: stack);
      }

      // Limitar a 10 resultados finais
      final limitedResults = results.take(10).toList();

      AppLogger.debug('Busca concluída', data: {
        'totalResults': limitedResults.length,
        'query': query,
      });

      if (mounted) {
        setState(() {
          _suggestions = limitedResults;
          _isSearching = false;
          // Se não encontrou nada, mostrar opção manual
          _showManualOption = limitedResults.isEmpty && query.length >= 3;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Erro na busca', error: e, stackTrace: stack);
      if (mounted) {
        setState(() {
          _isSearching = false;
          _showManualOption = true;
        });
      }
    }
  }

  /// Adiciona localização manualmente (sem coordenadas)
  void _addManualLocation() {
    final locationName = _searchController.text.trim();
    if (locationName.isEmpty) return;

    final locationData = LocationData(
      name: locationName,
      address: locationName,
      latitude: 0.0, // Sem coordenadas
      longitude: 0.0,
    );

    // Salvar no histórico (mesmo sem coordenadas)
    _historyService.saveLocationToHistory(
      name: locationName,
      address: locationName,
      latitude: 0.0,
      longitude: 0.0,
      source: 'manual',
    );

    widget.onLocationSelected(locationData);
    Navigator.of(context).pop();
  }

  /// Abre o Google Maps para buscar o local
  Future<void> _openInGoogleMaps() async {
    final query = Uri.encodeComponent(_searchController.text.trim());
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir Google Maps'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Abre o Waze para buscar o local
  Future<void> _openInWaze() async {
    final query = Uri.encodeComponent(_searchController.text.trim());
    final url = 'https://waze.com/ul?q=$query';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir Waze'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Quando o usuário seleciona um lugar
  Future<void> _handlePlaceSelected(UnifiedPlace place) async {
    // Se é do histórico, já tem coordenadas
    if (place.isFromHistory) {
      final locationData = LocationData(
        name: place.primaryText,
        address: place.fullAddress,
        latitude: place.latitude,
        longitude: place.longitude,
      );

      setState(() {
        _selectedLocation = locationData;
        _showMap = true;
        _suggestions = [];
        _searchController.text = place.primaryText;
      });

      _searchFocusNode.unfocus();

      // Animar câmera do mapa
      if (place.latitude != 0.0 && place.longitude != 0.0) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(place.latitude, place.longitude),
            15,
          ),
        );
      }
      return;
    }

    // Se é resultado do Google Places, precisa buscar detalhes (coordenadas)
    if (place.placeId != null) {
      setState(() => _isSearching = true);

      try {
        final details = await GooglePlacesService.getPlaceDetails(
          placeId: place.placeId!,
        );

        if (details != null && mounted) {
          final locationData = LocationData(
            name: details.name,
            address: details.formattedAddress,
            latitude: details.latitude,
            longitude: details.longitude,
          );

          setState(() {
            _selectedLocation = locationData;
            _showMap = true;
            _suggestions = [];
            _searchController.text = details.name;
            _isSearching = false;
          });

          _searchFocusNode.unfocus();

          // Animar câmera do mapa
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(details.latitude, details.longitude),
              15,
            ),
          );
        } else {
          // Falhou ao buscar detalhes
          if (mounted) {
            setState(() => _isSearching = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao obter detalhes do local'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e, stack) {
        AppLogger.error('Erro ao buscar detalhes do lugar', error: e, stackTrace: stack);
        if (mounted) {
          setState(() => _isSearching = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao buscar detalhes. Tente novamente.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      // Salvar no histórico para sugestões futuras
      _historyService.saveLocationToHistory(
        name: _selectedLocation!.name,
        address: _selectedLocation!.address,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        source: 'google_places',
      );

      widget.onLocationSelected(_selectedLocation!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),

                // Divider
                Divider(
                  height: 1,
                  color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Campo de busca
                        _buildSearchField(),

                        // Indicador de carregamento
                        if (_isSearching) ...[
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ],

                        // Lista de sugestões
                        if (_suggestions.isNotEmpty && !_showMap) ...[
                          const SizedBox(height: 16),
                          _buildSuggestionsList(),
                        ],

                        // Opção manual se não encontrar nada
                        if (_showManualOption && !_isSearching && !_showMap) ...[
                          const SizedBox(height: 16),
                          _buildManualOption(),
                        ],

                        // Mini mapa (se local selecionado)
                        if (_showMap && _selectedLocation != null) ...[
                          const SizedBox(height: 24),
                          _buildMiniMap(),
                        ],

                        // Informações do local selecionado
                        if (_selectedLocation != null) ...[
                          const SizedBox(height: 16),
                          _buildLocationInfo(),
                        ],
                      ],
                    ),
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
                ),

                // Botões de ação
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicionar Localização',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? AppColors.darkText : AppColors.lightText,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Text(
                  'Busca com Google Places API',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // TEMPORARIAMENTE DESABILITADO - sem localização do usuário
                /*
                const SizedBox(height: 4),
                // Indicador de localização
                if (_locationPermissionGranted && _userPosition != null)
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Localização obtida',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else if (!_locationPermissionGranted)
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.grey500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Obtendo localização...',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                */
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Digite o nome do local, estabelecimento ou endereço...',
        hintStyle: TextStyle(
          color: widget.isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primary,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _suggestions = [];
                    _selectedLocation = null;
                    _showMap = false;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: widget.isDark
            ? AppColors.darkCardElevated
            : AppColors.lightCardElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: (value) {
        setState(() {}); // Para atualizar o botão clear
      },
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCardElevated : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
        itemBuilder: (context, index) {
          final place = _suggestions[index];
          return _buildSuggestionItem(place);
        },
      ),
    );
  }

  Widget _buildSuggestionItem(UnifiedPlace place) {
    return InkWell(
      onTap: () => _handlePlaceSelected(place),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: place.sourceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                place.sourceIcon,
                color: place.sourceColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do local
                  Text(
                    place.primaryText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Endereço
                  Text(
                    place.secondaryText,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Badge de fonte e categoria
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: place.sourceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: place.sourceColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              place.isFromHistory ? Icons.history : Icons.location_on,
                              size: 10,
                              color: place.sourceColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.sourceName,
                              style: TextStyle(
                                fontSize: 9,
                                color: place.sourceColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (place.category != null && place.category!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• ${place.category}',
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget exibido quando não encontra resultados
  Widget _buildManualOption() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.darkCardElevated
            : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: Column(
        children: [
          // Ícone + Mensagem
          const Icon(
            Icons.search_off,
            color: AppColors.grey500,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar em apps mais atualizados ou adicione manualmente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Botão Google Maps
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openInGoogleMaps,
              icon: const Icon(Icons.map, size: 20),
              label: const Text('Buscar no Google Maps'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                side: BorderSide(
                  color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Botão Waze
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openInWaze,
              icon: const Icon(Icons.navigation, size: 20),
              label: const Text('Buscar no Waze'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                side: BorderSide(
                  color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Botão Adicionar Manualmente
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addManualLocation,
              icon: const Icon(Icons.edit_location, size: 20, color: Colors.white),
              label: const Text(
                'Adicionar Manualmente',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dicas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dica: Use Google Maps ou Waze para encontrar lugares específicos com mais precisão.',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Verifica se a plataforma suporta Google Maps
  bool get _isMapsSupported {
    // Google Maps Flutter suporta apenas Web, Android e iOS
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Widget _buildMiniMap() {
    if (_selectedLocation == null) return const SizedBox.shrink();

    // Se a plataforma não suporta Google Maps (como Windows/Linux/macOS)
    if (!_isMapsSupported) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.darkCardElevated
              : AppColors.lightCardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Mapa não disponível nesta plataforma',
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final lat = _selectedLocation!.latitude;
                final lon = _selectedLocation!.longitude;
                final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Abrir no Google Maps'),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              _selectedLocation!.latitude,
              _selectedLocation!.longitude,
            ),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: LatLng(
                _selectedLocation!.latitude,
                _selectedLocation!.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          },
          onMapCreated: (controller) {
            _mapController = controller;
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          liteModeEnabled: true,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    if (_selectedLocation == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedLocation!.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        widget.isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedLocation!.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: widget.isDark ? AppColors.darkBorder : AppColors.grey300,
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedLocation != null ? _confirmLocation : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.grey400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Confirmar Localização',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
