import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/company_model.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CompanyCard({
    super.key,
    required this.company,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _getTypeLabel(String type) {
    switch (type) {
      case 'mei':
        return 'MEI';
      case 'small':
        return 'Pequena Empresa';
      case 'services':
        return 'Serviços';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'mei':
        return const Color(0xFFFFD700); // Dourado
      case 'small':
        return AppColors.primary;
      case 'services':
        return const Color(0xFF9C27B0); // Roxo
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withOpacity(0.1)
              : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Logo ou ícone
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(company.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.business,
                      color: _getTypeColor(company.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nome e tipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimary : AppColors.lightText,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(company.type).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getTypeLabel(company.type),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getTypeColor(company.type),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            if (!company.isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Inativa',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu de ações
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    ),
                    color: isDark ? AppColors.darkSurface : AppColors.lightCard,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: onEdit,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: isDark ? AppColors.textPrimary : AppColors.lightText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: onDelete,
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Deletar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Descrição (se houver)
              if (company.description != null && company.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  company.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withOpacity(0.8),
                    fontFamily: 'Inter',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // CNPJ (se houver)
              if (company.cnpj != null && company.cnpj!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 14,
                      color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CNPJ: ${company.cnpj}',
                      style: TextStyle(
                        fontSize: 11,
                        color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withOpacity(0.6),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
