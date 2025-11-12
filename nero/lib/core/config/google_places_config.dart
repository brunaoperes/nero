/// Configuração do Google Places API
///
/// 🎯 Sistema Híbrido Inteligente
/// ✅ Tier gratuito: $200/mês (≈70.000 requisições)
/// ✅ Autocomplete: $2.83 por 1.000 requisições
/// ✅ Fallback automático quando exceder limite
///
/// Como obter sua API Key GRATUITA:
/// 1. Acesse: https://console.cloud.google.com/
/// 2. Crie/selecione um projeto
/// 3. Ative "Places API"
/// 4. Vá em "Credenciais" → "Criar credenciais" → "Chave de API"
/// 5. Copie sua API Key
/// 6. Cole abaixo na constante GOOGLE_PLACES_API_KEY
class GooglePlacesConfig {
  GooglePlacesConfig._();

  /// 🔑 SUA API KEY GRATUITA DO GOOGLE PLACES
  ///
  /// ✅ API Key configurada!
  /// Tier Gratuito: $200/mês (~70.000 requisições)
  static const String GOOGLE_PLACES_API_KEY = 'AIzaSyB4e8oSVyqI1NTL59cwy6HUjkXMwRDCss0';

  /// URL base da API Google Places
  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// Endpoint de autocomplete
  static String get autocompleteUrl => '$baseUrl/autocomplete/json';

  /// Endpoint de detalhes do lugar
  static String get detailsUrl => '$baseUrl/details/json';

  /// Configurações padrão
  static const String defaultLanguage = 'pt-BR';
  static const String defaultCountryCode = 'br';
  static const int defaultRadius = 50000; // 50km em metros

  /// 🚨 Configuração de Limites e Fallback
  /// Quando usar Google Places vs quando fazer fallback

  /// Custo estimado por requisição (em dólares)
  static const double costPerRequest = 0.00283; // $2.83 por 1.000

  /// Limite mensal do crédito grátis (em dólares)
  static const double monthlyFreeCredit = 200.0;

  /// Máximo de requisições mensais antes do fallback
  /// $200 ÷ $0.00283 = ~70.000 requisições
  static const int maxMonthlyRequests = 70000;

  /// Limite de segurança (80% do máximo)
  /// Ativa fallback em ~56.000 requisições
  static const int safetyLimitRequests = 56000;

  /// Verifica se a API Key foi configurada
  static bool get isConfigured => GOOGLE_PLACES_API_KEY != 'YOUR_API_KEY_HERE';

  /// Chave para armazenar contador de requisições
  static const String requestCountKey = 'google_places_request_count';
  static const String requestMonthKey = 'google_places_request_month';
}
