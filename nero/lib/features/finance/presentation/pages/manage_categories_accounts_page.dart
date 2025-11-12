import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/accounts_provider.dart';

/// Página para gerenciar categorias e contas
class ManageCategoriesAccountsPage extends ConsumerStatefulWidget {
  const ManageCategoriesAccountsPage({super.key});

  @override
  ConsumerState<ManageCategoriesAccountsPage> createState() => _ManageCategoriesAccountsPageState();
}

class _ManageCategoriesAccountsPageState extends ConsumerState<ManageCategoriesAccountsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias e Contas'),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.textPrimary : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondary : Colors.grey,
          tabs: const [
            Tab(text: 'Despesas', icon: Icon(Icons.arrow_downward, size: 20)),
            Tab(text: 'Receitas', icon: Icon(Icons.arrow_upward, size: 20)),
            Tab(text: 'Contas', icon: Icon(Icons.account_balance_wallet, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesList(
            ref.watch(expenseCategoriesProvider),
            ref.read(expenseCategoriesProvider.notifier),
            'despesas',
            isDark,
          ),
          _buildCategoriesList(
            ref.watch(incomeCategoriesProvider),
            ref.read(incomeCategoriesProvider.notifier),
            'receitas',
            isDark,
          ),
          _buildAccountsList(
            ref.watch(accountsProvider),
            ref.read(accountsProvider.notifier),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    List<String> categories,
    CategoriesNotifier notifier,
    String type,
    bool isDark,
  ) {
    return Column(
      children: [
        // Header com botão adicionar
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${categories.length} categoria${categories.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddDialog(notifier, type, isDark),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showRestoreDialog(notifier, type, isDark),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restaurar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de categorias
        Expanded(
          child: categories.isEmpty
              ? _buildEmptyState('Nenhuma categoria de $type', isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryItem(category, notifier, type, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAccountsList(
    List<String> accounts,
    AccountsNotifier notifier,
    bool isDark,
  ) {
    return Column(
      children: [
        // Header com botão adicionar
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${accounts.length} conta${accounts.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddAccountDialog(notifier, isDark),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showRestoreAccountsDialog(notifier, isDark),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restaurar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de contas
        Expanded(
          child: accounts.isEmpty
              ? _buildEmptyState('Nenhuma conta cadastrada', isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _buildAccountItem(account, notifier, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    String category,
    CategoriesNotifier notifier,
    String type,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            type == 'despesas' ? Icons.arrow_downward : Icons.arrow_upward,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          category,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimary : AppColors.lightText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: isDark ? AppColors.textSecondary : Colors.grey,
                size: 20,
              ),
              onPressed: () => _showEditDialog(notifier, category, type, isDark),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _showDeleteDialog(notifier, category, type, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(
    String account,
    AccountsNotifier notifier,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          account,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimary : AppColors.lightText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: isDark ? AppColors.textSecondary : Colors.grey,
                size: 20,
              ),
              onPressed: () => _showEditAccountDialog(notifier, account, isDark),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _showDeleteAccountDialog(notifier, account, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: isDark ? AppColors.textSecondary : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Diálogos
  Future<void> _showAddDialog(CategoriesNotifier notifier, String type, bool isDark) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Adicionar Categoria',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ex: Combustível, Assinaturas...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await notifier.addCategory(controller.text.trim());
                if (mounted) Navigator.pop(context);
                _showSnackBar('Categoria adicionada com sucesso!', AppColors.success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    CategoriesNotifier notifier,
    String category,
    String type,
    bool isDark,
  ) async {
    final controller = TextEditingController(text: category);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Editar Categoria',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await notifier.editCategory(category, controller.text.trim());
                if (mounted) Navigator.pop(context);
                _showSnackBar('Categoria atualizada!', AppColors.success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    CategoriesNotifier notifier,
    String category,
    String type,
    bool isDark,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Excluir Categoria',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: Text(
          'Deseja realmente excluir a categoria "$category"?',
          style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.removeCategory(category);
              if (mounted) Navigator.pop(context);
              _showSnackBar('Categoria removida!', AppColors.error);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog(CategoriesNotifier notifier, String type, bool isDark) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Restaurar Padrões',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: Text(
          'Deseja restaurar as categorias padrão de $type? Todas as personalizações serão perdidas.',
          style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.restoreDefaults();
              if (mounted) Navigator.pop(context);
              _showSnackBar('Categorias restauradas!', Colors.orange);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  // Accounts dialogs
  Future<void> _showAddAccountDialog(AccountsNotifier notifier, bool isDark) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Adicionar Conta',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ex: Caixa PJ, Carteira Be Coffee...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await notifier.addAccount(controller.text.trim());
                if (mounted) Navigator.pop(context);
                _showSnackBar('Conta adicionada com sucesso!', AppColors.success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditAccountDialog(
    AccountsNotifier notifier,
    String account,
    bool isDark,
  ) async {
    final controller = TextEditingController(text: account);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Editar Conta',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await notifier.editAccount(account, controller.text.trim());
                if (mounted) Navigator.pop(context);
                _showSnackBar('Conta atualizada!', AppColors.success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    AccountsNotifier notifier,
    String account,
    bool isDark,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Excluir Conta',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: Text(
          'Deseja realmente excluir a conta "$account"?',
          style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.removeAccount(account);
              if (mounted) Navigator.pop(context);
              _showSnackBar('Conta removida!', AppColors.error);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreAccountsDialog(AccountsNotifier notifier, bool isDark) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Restaurar Padrões',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightText),
        ),
        content: Text(
          'Deseja restaurar as contas padrão? Todas as personalizações serão perdidas.',
          style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.restoreDefaults();
              if (mounted) Navigator.pop(context);
              _showSnackBar('Contas restauradas!', Colors.orange);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
