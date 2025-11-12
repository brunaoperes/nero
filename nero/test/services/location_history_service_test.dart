import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nero/core/services/location_history_service.dart';

void main() {
  group('LocationHistoryService', () {
    late LocationHistoryService service;
    late Directory testDir;

    setUpAll(() async {
      // Criar diretório temporário para testes
      testDir = await Directory.systemTemp.createTemp('hive_test_');

      // Inicializar Hive com diretório temporário
      Hive.init(testDir.path);
      await LocationHistoryService.initialize();
    });

    setUp(() async {
      service = LocationHistoryService();
      // Garantir que o histórico está limpo antes de cada teste
      await service.clearHistory();
    });

    tearDown(() async {
      // Limpar dados de teste após cada teste
      await service.clearHistory();
    });

    tearDownAll(() async {
      // Fechar Hive e limpar diretório temporário
      await Hive.close();

      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('Deve salvar uma localização no histórico', () async {
      await service.saveLocationToHistory(
        name: 'Restaurante Teste',
        address: 'Rua Teste, 123',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      final history = service.getAllHistory();

      expect(history.length, 1);
      expect(history.first['name'], 'Restaurante Teste');
      expect(history.first['address'], 'Rua Teste, 123');
      expect(history.first['latitude'], -23.5505);
      expect(history.first['longitude'], -46.6333);
      expect(history.first['useCount'], 1);
    });

    test('Deve incrementar useCount ao salvar localização duplicada', () async {
      // Salvar pela primeira vez
      await service.saveLocationToHistory(
        name: 'Local Teste',
        address: 'Endereço Teste',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      // Salvar novamente (mesmo nome)
      await service.saveLocationToHistory(
        name: 'Local Teste',
        address: 'Endereço Teste',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      final history = service.getAllHistory();

      expect(history.length, 1); // Não deve duplicar
      expect(history.first['useCount'], 2); // useCount incrementado
    });

    test('Deve retornar histórico vazio quando não há dados', () {
      final history = service.getAllHistory();
      expect(history, isEmpty);
    });

    test('Deve limpar todo o histórico', () async {
      // Salvar alguns locais
      await service.saveLocationToHistory(
        name: 'Local 1',
        address: 'Endereço 1',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      await service.saveLocationToHistory(
        name: 'Local 2',
        address: 'Endereço 2',
        latitude: -23.5600,
        longitude: -46.6400,
      );

      // Limpar histórico
      await service.clearHistory();

      final history = service.getAllHistory();
      expect(history, isEmpty);
    });

    test('Deve remover um local específico do histórico', () async {
      // Salvar alguns locais
      await service.saveLocationToHistory(
        name: 'Local 1',
        address: 'Endereço 1',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      await service.saveLocationToHistory(
        name: 'Local 2',
        address: 'Endereço 2',
        latitude: -23.5600,
        longitude: -46.6400,
      );

      // Remover "Local 1"
      await service.removeFromHistory('Local 1');

      final history = service.getAllHistory();

      expect(history.length, 1);
      expect(history.first['name'], 'Local 2');
    });

    test('Deve retornar sugestões inteligentes baseadas na query', () async {
      // Salvar alguns locais
      await service.saveLocationToHistory(
        name: 'Restaurante Pizza',
        address: 'Rua A, 100',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      await service.saveLocationToHistory(
        name: 'Pizzaria Bella',
        address: 'Rua B, 200',
        latitude: -23.5600,
        longitude: -46.6400,
      );

      await service.saveLocationToHistory(
        name: 'Cafeteria Legal',
        address: 'Rua C, 300',
        latitude: -23.5700,
        longitude: -46.6500,
      );

      // Buscar por "pizza"
      final suggestions = service.getSmartSuggestions(query: 'pizza', limit: 5);

      // Deve retornar resultados que contenham "pizza" no nome
      expect(suggestions.length, greaterThanOrEqualTo(2));

      // Verificar que os resultados contêm "Pizza" (case insensitive)
      final pizzaResults = suggestions.where((s) =>
        (s['name'] as String).toLowerCase().contains('pizza')
      ).toList();

      expect(pizzaResults.length, 2);
      expect(pizzaResults[0]['name'], anyOf(contains('Pizza'), contains('Pizzaria')));
      expect(pizzaResults[1]['name'], anyOf(contains('Pizza'), contains('Pizzaria')));
    });

    test('Deve ordenar sugestões por relevância e frequência', () async {
      // Salvar "Local 1" uma vez
      await service.saveLocationToHistory(
        name: 'Local 1',
        address: 'Endereço 1',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      // Salvar "Local 2" três vezes
      for (int i = 0; i < 3; i++) {
        await service.saveLocationToHistory(
          name: 'Local 2',
          address: 'Endereço 2',
          latitude: -23.5600,
          longitude: -46.6400,
        );
      }

      // Buscar sem query (ordenar por frequência)
      final suggestions = service.getSmartSuggestions(limit: 5);

      expect(suggestions.length, 2);
      expect(suggestions.first['name'], 'Local 2'); // Mais frequente primeiro
      expect(suggestions.first['useCount'], 3);
    });

    test('Deve limitar o número de sugestões retornadas', () async {
      // Salvar vários locais
      for (int i = 0; i < 10; i++) {
        await service.saveLocationToHistory(
          name: 'Local $i',
          address: 'Endereço $i',
          latitude: -23.5505 + (i * 0.01),
          longitude: -46.6333 + (i * 0.01),
        );
      }

      final suggestions = service.getSmartSuggestions(limit: 3);

      expect(suggestions.length, 3);
    });

    test('Deve detectar locais duplicados por coordenadas próximas', () async {
      // Salvar local
      await service.saveLocationToHistory(
        name: 'Local Original',
        address: 'Endereço Original',
        latitude: -23.5505,
        longitude: -46.6333,
      );

      // Salvar local com coordenadas MUITO próximas (raio de ~5 metros)
      await service.saveLocationToHistory(
        name: 'Local Próximo',
        address: 'Endereço Próximo',
        latitude: -23.5506, // Diferença de ~0.01 grau
        longitude: -46.6334,
      );

      final history = service.getAllHistory();

      // Deve ter detectado como duplicata
      expect(history.length, 1);
      expect(history.first['useCount'], 2);
    });
  });
}
