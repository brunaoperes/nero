import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../sync/presentation/widgets/sync_status_indicator.dart';

/// Header do Dashboard com efeito blur e toggle de tema
class DashboardHeader extends ConsumerWidget {
  final String userName;
  final bool hasNotifications;
  final VoidCallback? onNotificationTap;
  final bool isScrolled;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.hasNotifications = false,
    this.onNotificationTap,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.debug('Header build iniciado');

    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final themeNotifier = ref.read(themeProvider.notifier);

    // Obter altura da barra de status
    final statusBarHeight = MediaQuery.of(context).padding.top;

    AppLogger.debug('Header layout', data: {
      'statusBarHeight': statusBarHeight,
      'isScrolled': isScrolled,
      'paddingTop': statusBarHeight + 12,
    });

    // Responsivo: reduzir padding lateral em telas pequenas
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 400 ? 16.0 : 20.0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isScrolled ? 10 : 0,
          sigmaY: isScrolled ? 10 : 0,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            statusBarHeight + 12,
            horizontalPadding,
            16,
          ),
          decoration: BoxDecoration(
            color: isScrolled
                ? (isDark
                    ? AppColors.darkBackground.withOpacity(0.9)
                    : AppColors.lightBackground.withOpacity(0.9))
                : Colors.transparent,
            border: isScrolled
                ? Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.grey300,
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  AppLogger.debug('Header container interno', data: {'size': renderBox.size.toString()});
                }
              });

              return Row(
                children: [
                  // Avatar e Saudação
                  Expanded(
                    child: Row(
                      children: [
                        // Avatar
                        Builder(
                          builder: (context) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final renderBox = context.findRenderObject() as RenderBox?;
                              if (renderBox != null) {
                                AppLogger.debug('Header avatar', data: {
                                  'size': renderBox.size.toString(),
                                  'position': renderBox.localToGlobal(Offset.zero).toString(),
                                });
                              }
                            });

                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),

                        // Saudação
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final renderBox = context.findRenderObject() as RenderBox?;
                                if (renderBox != null) {
                                  AppLogger.debug('Header greeting', data: {
                                    'size': renderBox.size.toString(),
                                    'position': renderBox.localToGlobal(Offset.zero).toString(),
                                  });
                                }
                              });

                              // Responsivo: ajustar fonte em telas pequenas
                              final screenWidth = MediaQuery.of(context).size.width;
                              final isCompact = screenWidth < 400;
                              final greetingSize = isCompact ? 12.0 : 14.0;
                              final nameSize = isCompact ? 16.0 : 18.0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: greetingSize,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: nameSize,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ações
                  Builder(
                    builder: (context) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final renderBox = context.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          AppLogger.debug('Header actions', data: {
                            'size': renderBox.size.toString(),
                            'position': renderBox.localToGlobal(Offset.zero).toString(),
                          });
                        }
                      });

                      // Responsivo: ajustar tamanhos baseado na largura da tela
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isCompact = screenWidth < 400;
                      final iconSize = isCompact ? 18.0 : 20.0;
                      final iconPadding = isCompact ? 6.0 : 8.0;
                      final gap = isCompact ? 6.0 : 8.0;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sync Status Indicator (compacto em mobile)
                          if (!isCompact) ...[
                            const SyncStatusIndicator(),
                            SizedBox(width: gap),
                          ],

                          // Busca Global
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => context.push('/search'),
                              child: Container(
                                padding: EdgeInsets.all(iconPadding),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.grey300,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: gap),

                          // Toggle de Tema
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => themeNotifier.toggleTheme(),
                              child: Container(
                                padding: EdgeInsets.all(iconPadding),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.grey300,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: gap),

                          // Notificações
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: onNotificationTap,
                              child: Container(
                                padding: EdgeInsets.all(iconPadding),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.grey300,
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications_outlined,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                      size: iconSize,
                                    ),
                                    if (hasNotifications)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.error,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia,';
    } else if (hour < 18) {
      return 'Boa tarde,';
    } else {
      return 'Boa noite,';
    }
  }
}
