/// Configuração do Geoapify Maps API
///
/// 🎯 100% GRATUITO
/// ✅ Tier gratuito: 3.000 requisições/dia
/// ✅ Sem cartão de crédito necessário
/// ✅ Dados atualizados e completos
///
/// Como obter sua API Key GRATUITA:
/// 1. Acesse: https://www.geoapify.com/
/// 2. Clique em "Get Started Free"
/// 3. Crie conta gratuita (sem cartão)
/// 4. Copie sua API Key do dashboard
/// 5. Cole abaixo na constante GEOAPIFY_API_KEY
class GeoapifyConfig {
  GeoapifyConfig._();

  /// 🔑 SUA API KEY GRATUITA DO GEOAPIFY
  ///
  /// ✅ API Key configurada!
  /// Tier Gratuito: 3.000 requisições/dia
  static const String GEOAPIFY_API_KEY = '64eb6820de744a03a6b414e9e9ee4c27';

  /// URL base da API Geoapify
  static const String baseUrl = 'https://api.geoapify.com/v1';

  /// Endpoint de autocomplete (busca inteligente)
  static String get autocompleteUrl => '$baseUrl/geocode/autocomplete';

  /// Endpoint de geocoding reverso (coordenadas → endereço)
  static String get reverseUrl => '$baseUrl/geocode/reverse';

  /// Configurações padrão
  static const String defaultLanguage = 'pt';
  static const String defaultCountryCode = 'br';
  static const int defaultLimit = 5;

  /// Verifica se a API Key foi configurada
  static bool get isConfigured => GEOAPIFY_API_KEY != 'YOUR_API_KEY_HERE';
}
