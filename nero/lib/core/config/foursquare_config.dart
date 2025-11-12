/// Configuração do Foursquare Places API
///
/// 🎯 100% GRATUITO
/// ✅ Tier gratuito: 95.000 requisições/mês
/// ✅ Excelente para estabelecimentos comerciais e POIs
/// ✅ Retorna: nome, endereço, categoria, coordenadas
///
/// Como obter sua API Key GRATUITA:
/// 1. Acesse: https://foursquare.com/developers/
/// 2. Clique em "Get Started"
/// 3. Crie conta gratuita (sem cartão)
/// 4. Crie um novo projeto
/// 5. Copie sua API Key
/// 6. Cole abaixo na constante FOURSQUARE_API_KEY
class FoursquareConfig {
  FoursquareConfig._();

  /// 🔑 SUA API KEY GRATUITA DO FOURSQUARE
  ///
  /// ✅ API Key configurada!
  /// Tier Gratuito: 95.000 requisições/mês
  static const String FOURSQUARE_API_KEY = 'fsq35LVN4KMJFQ2HW3G44LPBM2152KZMKWF5AJSKC3QHE1D4TP5Y';

  /// URL base da API Foursquare Places
  static const String baseUrl = 'https://api.foursquare.com/v3';

  /// Endpoint de busca de lugares
  static String get searchUrl => '$baseUrl/places/search';

  /// Endpoint de autocomplete
  static String get autocompleteUrl => '$baseUrl/autocomplete';

  /// Configurações padrão
  static const String defaultLocation = 'São Paulo, Brasil';
  static const int defaultLimit = 5;
  static const int defaultRadius = 50000; // 50km em metros

  /// Verifica se a API Key foi configurada
  static bool get isConfigured => FOURSQUARE_API_KEY != 'YOUR_API_KEY_HERE';
}
