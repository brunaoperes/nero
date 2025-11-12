import 'package:flutter/material.dart';

/// Informações sobre bancos e instituições financeiras
class BankInfo {
  final String key;
  final String name;
  final String icon; // Emoji fallback
  final String logoText; // Texto para logo (iniciais ou símbolo)
  final Color color;
  final Color? textColor; // Cor do texto do logo (padrão: branco)

  const BankInfo({
    required this.key,
    required this.name,
    required this.icon,
    required this.logoText,
    required this.color,
    this.textColor,
  });
}

/// Lista de bancos disponíveis
class BankIcons {
  static const List<BankInfo> banks = [
    BankInfo(
      key: 'nubank',
      name: 'Nubank',
      icon: '💜',
      logoText: 'Nu',
      color: Color(0xFF820AD1),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'itau',
      name: 'Itaú',
      icon: '🔶',
      logoText: 'itaú',
      color: Color(0xFFEC7000),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'bradesco',
      name: 'Bradesco',
      icon: '🔴',
      logoText: 'BR',
      color: Color(0xFFCC092F),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'caixa',
      name: 'Caixa Econômica',
      icon: '🔵',
      logoText: 'CEF',
      color: Color(0xFF0D47A1),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'santander',
      name: 'Santander',
      icon: '🔥',
      logoText: 'S',
      color: Color(0xFFEC0000),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'c6',
      name: 'C6 Bank',
      icon: '⚫',
      logoText: 'C6',
      color: Color(0xFF212121),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'inter',
      name: 'Inter',
      icon: '🟠',
      logoText: '⚡',
      color: Color(0xFFFF7A00),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'xp',
      name: 'XP Investimentos',
      icon: '💸',
      logoText: 'XP',
      color: Color(0xFF000000),
      textColor: Color(0xFFFFC700),
    ),
    BankInfo(
      key: 'wallet',
      name: 'Carteira / Dinheiro',
      icon: '💰',
      logoText: '\$',
      color: Color(0xFF4CAF50),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'poupanca',
      name: 'Poupança',
      icon: '🐷',
      logoText: '⭐',
      color: Color(0xFFFF9800),
      textColor: Colors.white,
    ),
    BankInfo(
      key: 'generic',
      name: 'Outro',
      icon: '🏦',
      logoText: '🏦',
      color: Color(0xFF757575),
      textColor: Colors.white,
    ),
  ];

  /// Busca informações do banco pela chave
  static BankInfo getBankInfo(String key) {
    return banks.firstWhere(
      (bank) => bank.key == key,
      orElse: () => banks.last, // retorna generic
    );
  }

  /// Busca informações do banco pelo nome (busca parcial)
  static BankInfo getBankInfoByName(String name) {
    final lowerName = name.toLowerCase();
    return banks.firstWhere(
      (bank) => lowerName.contains(bank.name.toLowerCase()),
      orElse: () => banks.last,
    );
  }
}
