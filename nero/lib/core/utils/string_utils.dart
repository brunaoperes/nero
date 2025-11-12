/// Utilitários para manipulação de strings
///
/// Inclui funções para normalização de texto, remoção de acentos,
/// e comparação fuzzy para autocomplete inteligente.
library;

/// Remove acentos de uma string
String removeDiacritics(String str) {
  const diacritics = {
    'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
    'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
    'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
    'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
    'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ô': 'O', 'Ö': 'O',
    'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
    'Ç': 'C', 'Ñ': 'N',
  };

  var result = str;
  diacritics.forEach((key, value) {
    result = result.replaceAll(key, value);
  });
  return result;
}

/// Normaliza uma string para busca:
/// - Remove acentos
/// - Converte para minúsculas
/// - Colapsa espaços múltiplos em um único espaço
/// - Remove espaços no início e fim
String normalizeForSearch(String str) {
  return removeDiacritics(str.trim().toLowerCase())
      .replaceAll(RegExp(r'\s+'), ' ');
}

/// Calcula a distância de Levenshtein entre duas strings
/// (número mínimo de edições necessárias para transformar uma string em outra)
int levenshteinDistance(String s1, String s2) {
  if (s1 == s2) return 0;
  if (s1.isEmpty) return s2.length;
  if (s2.isEmpty) return s1.length;

  final len1 = s1.length;
  final len2 = s2.length;

  // Matriz de distâncias
  final matrix = List.generate(
    len1 + 1,
    (i) => List.filled(len2 + 1, 0),
  );

  // Inicializar primeira linha e coluna
  for (var i = 0; i <= len1; i++) {
    matrix[i][0] = i;
  }
  for (var j = 0; j <= len2; j++) {
    matrix[0][j] = j;
  }

  // Calcular distâncias
  for (var i = 1; i <= len1; i++) {
    for (var j = 1; j <= len2; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,      // Deleção
        matrix[i][j - 1] + 1,      // Inserção
        matrix[i - 1][j - 1] + cost, // Substituição
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  return matrix[len1][len2];
}

/// Calcula score de similaridade entre duas strings (0.0 a 1.0)
/// Usa distância de Levenshtein normalizada
double similarityScore(String s1, String s2) {
  final distance = levenshteinDistance(s1.toLowerCase(), s2.toLowerCase());
  final maxLen = s1.length > s2.length ? s1.length : s2.length;
  if (maxLen == 0) return 1.0;
  return 1.0 - (distance / maxLen);
}

/// Verifica se uma string contém outra (case-insensitive, sem acentos)
bool fuzzyContains(String text, String query) {
  final normalizedText = normalizeForSearch(text);
  final normalizedQuery = normalizeForSearch(query);
  return normalizedText.contains(normalizedQuery);
}

/// Verifica se uma string começa com outra (case-insensitive, sem acentos)
bool fuzzyStartsWith(String text, String query) {
  final normalizedText = normalizeForSearch(text);
  final normalizedQuery = normalizeForSearch(query);
  return normalizedText.startsWith(normalizedQuery);
}
