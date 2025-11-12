import 'package:flutter/material.dart';
import '../constants/bank_icons.dart';

/// Widget para exibir o logo de um banco com suas cores e iniciais
class BankLogo extends StatelessWidget {
  final BankInfo bankInfo;
  final double size;
  final double? borderRadius;

  const BankLogo({
    super.key,
    required this.bankInfo,
    this.size = 48,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size * 0.25; // 25% do tamanho por padrão

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bankInfo.color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: bankInfo.color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          bankInfo.logoText,
          style: TextStyle(
            color: bankInfo.textColor ?? Colors.white,
            fontSize: _calculateFontSize(),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  double _calculateFontSize() {
    // Ajusta o tamanho da fonte baseado no tamanho do container
    // e no comprimento do texto
    if (bankInfo.logoText.length == 1) {
      return size * 0.5; // Letra única: 50% do tamanho
    } else if (bankInfo.logoText.length == 2) {
      return size * 0.4; // Duas letras: 40% do tamanho
    } else if (bankInfo.logoText.length == 3) {
      return size * 0.32; // Três letras: 32% do tamanho
    } else {
      return size * 0.28; // Mais letras: 28% do tamanho
    }
  }
}
