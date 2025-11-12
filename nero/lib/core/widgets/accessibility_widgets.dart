import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../config/app_colors.dart';

/// Botão acessível com suporte a screen reader e navegação por teclado
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final bool enabled;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.enabled = true,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: child,
    );

    Widget result = Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: ExcludeSemantics(child: button),
    );

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return result;
  }
}

/// TextField acessível com labels semânticos
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? semanticLabel;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.semanticLabel,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      textField: true,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Card acessível com tooltip e feedback tátil
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final String? tooltip;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.tooltip,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    Widget result = Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: enabled,
      child: ExcludeSemantics(child: card),
    );

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return result;
  }
}

/// Texto com alto contraste para melhor legibilidade
class HighContrastText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool highContrast;

  const HighContrastText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.highContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    TextStyle effectiveStyle = style ?? const TextStyle();

    if (highContrast) {
      // Aumentar contraste para melhor legibilidade
      effectiveStyle = effectiveStyle.copyWith(
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            color: isDark ? Colors.black54 : Colors.white54,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      );
    }

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Ícone com tooltip para acessibilidade
class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final String? tooltip;
  final Color? color;
  final double? size;
  final VoidCallback? onTap;

  const AccessibleIcon({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.tooltip,
    this.color,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      color: color,
      size: size,
    );

    if (onTap != null) {
      iconWidget = IconButton(
        icon: iconWidget,
        onPressed: onTap,
      );
    }

    Widget result = Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: ExcludeSemantics(child: iconWidget),
    );

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return result;
  }
}

/// Switch acessível com label semântico
class AccessibleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? semanticLabel;

  const AccessibleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: semanticLabel ?? label,
        toggled: value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// ListTile acessível com suporte a navegação
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final String semanticLabel;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool enabled;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.semanticLabel,
    this.tooltip,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );

    Widget result = Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: enabled,
      child: ExcludeSemantics(child: tile),
    );

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return result;
  }
}

/// Helper para anunciar mensagens para screen readers
class A11yAnnouncer {
  /// Anuncia uma mensagem para screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(
      message,
      Directionality.of(context),
    );
  }

  /// Anuncia uma mensagem de erro
  static void announceError(BuildContext context, String message) {
    announce(context, message);
  }

  /// Anuncia uma mensagem de sucesso
  static void announceSuccess(BuildContext context, String message) {
    announce(context, message);
  }
}

/// Widget para navegação por teclado (Tab)
class KeyboardNavigationScope extends StatelessWidget {
  final Widget child;
  final FocusNode? focusNode;

  const KeyboardNavigationScope({
    super.key,
    required this.child,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: child,
    );
  }
}

/// Widget de ajuda com atalhos de teclado
class KeyboardShortcutsHelp extends StatelessWidget {
  final Map<String, String> shortcuts;

  const KeyboardShortcutsHelp({
    super.key,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Atalhos de Teclado'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: shortcuts.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

/// Extensão para facilitar o uso de Semantics
extension AccessibilityExtensions on Widget {
  /// Adiciona um label semântico ao widget
  Widget withSemantics({
    required String label,
    String? hint,
    bool? button,
    bool? enabled,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      enabled: enabled,
      child: this,
    );
  }

  /// Adiciona um tooltip ao widget
  Widget withTooltip(String message) {
    return Tooltip(
      message: message,
      child: this,
    );
  }

  /// Adiciona foco para navegação por teclado
  Widget withFocus({FocusNode? focusNode}) {
    return Focus(
      focusNode: focusNode,
      child: this,
    );
  }
}
