import 'package:flutter/material.dart';

/// Stub para PluggyConnectWidgetWeb (usado em mobile)
/// Este arquivo nunca é executado, apenas satisfaz o compilador
class PluggyConnectWidgetWeb extends StatelessWidget {
  final Function(String itemId) onSuccess;
  final Function(String error) onError;

  const PluggyConnectWidgetWeb({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Web version not available on mobile'),
    );
  }
}
