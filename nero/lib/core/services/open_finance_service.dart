import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/bank_connector_model.dart';
import '../../shared/models/bank_connection_model.dart';
import '../../shared/models/bank_account_model.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// Serviço para integração com Open Finance (Pluggy)
class OpenFinanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // URL do backend
  static const String baseUrl = AppConstants.backendUrl;

  /// Obter token de acesso do Pluggy Connect Widget
  Future<String> getConnectToken() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/open-finance/connect-token'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConstants.backendApiKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['accessToken'] as String;
      } else {
        throw Exception('Failed to get connect token: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Erro ao obter connect token', error: e);
      rethrow;
    }
  }

  /// Listar conectores bancários disponíveis
  Future<List<BankConnectorModel>> getConnectors({
    List<String>? types,
    List<String>? countries,
    String? name,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (types != null && types.isNotEmpty) {
        queryParams['types'] = types.join(',');
      }
      if (countries != null && countries.isNotEmpty) {
        queryParams['countries'] = countries.join(',');
      }
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }

      final uri = Uri.parse('$baseUrl/api/open-finance/connectors')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConstants.backendApiKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List connectorsList = data['data'] as List;
        return connectorsList
            .map((json) => BankConnectorModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get connectors: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Erro ao obter conectores', error: e);
      rethrow;
    }
  }

  /// Salvar uma nova conexão bancária após usuário conectar via widget
  Future<BankConnectionModel> createConnection(String itemId) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/open-finance/connections'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConstants.backendApiKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: json.encode({
          'itemId': itemId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return BankConnectionModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create connection: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Erro ao criar conexão', error: e);
      rethrow;
    }
  }

  /// Listar todas as conexões bancárias do usuário
  Future<List<BankConnectionModel>> getConnections() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/open-finance/connections'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConstants.backendApiKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List connectionsList = data['data'] as List;
        return connectionsList
            .map((json) => BankConnectionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get connections: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Erro ao obter conexões', error: e);
      rethrow;
    }
  }

  /// Sincronizar manualmente uma conexão bancária
  Future<Map<String, dynamic>> syncConnection(String connectionId) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/open-finance/connections/$connectionId/sync'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConstants.backendApiKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to sync connection: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Erro ao sincronizar conexão', error: e);
      rethrow;
    }
  }

  /// Deletar uma conexão bancária
  Future<void> deleteConnection(String connectionId) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/open-finance/connections/$connectionId'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConstants.backendApiKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete connection: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Erro ao deletar conexão', error: e);
      rethrow;
    }
  }

  /// Listar todas as contas bancárias do usuário
  Future<List<BankAccountModel>> getAccounts() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/open-finance/accounts'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConstants.backendApiKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List accountsList = data['data'] as List;
        return accountsList
            .map((json) => BankAccountModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get accounts: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Erro ao obter contas', error: e);
      rethrow;
    }
  }

  /// Obter resumo financeiro de todas as contas
  Future<Map<String, double>> getFinancialSummary() async {
    try {
      final accounts = await getAccounts();

      double totalBalance = 0;

      for (final account in accounts) {
        totalBalance += account.balance;
      }

      return {
        'bankBalance': totalBalance,
        'creditBalance': 0.0,
        'creditLimit': 0.0,
        'availableCredit': 0.0,
        'totalBalance': totalBalance,
      };
    } catch (e) {
      AppLogger.error('Erro ao obter resumo financeiro', error: e);
      rethrow;
    }
  }
}
