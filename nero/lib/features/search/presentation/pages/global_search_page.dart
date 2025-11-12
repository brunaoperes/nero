import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../providers/search_provider.dart';

/// Tela de Busca Global
class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final results = ref.watch(searchResultsProvider);
    final groupedResults = ref.watch(groupedSearchResultsProvider);
    final history = ref.watch(searchHistoryProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Buscar tarefas, finanças, empresas...',
            border: InputBorder.none,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              ref.read(searchHistoryProvider.notifier).addSearch(value);
            }
          },
        ),
      ),
      body: query.isEmpty
          ? _buildHistoryView(history, isDark)
          : results.isEmpty
              ? _buildEmptyState(isDark)
              : _buildResultsView(groupedResults, isDark),
    );
  }

  Widget _buildHistoryView(List<String> history, bool isDark) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Comece a buscar',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Buscas Recentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(searchHistoryProvider.notifier).clearHistory();
              },
              child: const Text('Limpar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...history.asMap().entries.map((entry) {
          return AnimatedListItem(
            index: entry.key,
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(entry.value),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  ref.read(searchHistoryProvider.notifier).removeSearch(entry.value);
                },
              ),
              onTap: () {
                _searchController.text = entry.value;
                ref.read(searchQueryProvider.notifier).state = entry.value;
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(Map<SearchResultType, List<SearchResult>> groupedResults, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (groupedResults[SearchResultType.task]!.isNotEmpty) ...[
          _buildSectionHeader('Tarefas', groupedResults[SearchResultType.task]!.length, isDark),
          const SizedBox(height: 12),
          ...groupedResults[SearchResultType.task]!.asMap().entries.map((entry) {
            return AnimatedListItem(
              index: entry.key,
              child: _buildTaskResult(entry.value, isDark),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (groupedResults[SearchResultType.transaction]!.isNotEmpty) ...[
          _buildSectionHeader('Finanças', groupedResults[SearchResultType.transaction]!.length, isDark),
          const SizedBox(height: 12),
          ...groupedResults[SearchResultType.transaction]!.asMap().entries.map((entry) {
            return AnimatedListItem(
              index: entry.key,
              child: _buildTransactionResult(entry.value, isDark),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (groupedResults[SearchResultType.company]!.isNotEmpty) ...[
          _buildSectionHeader('Empresas', groupedResults[SearchResultType.company]!.length, isDark),
          const SizedBox(height: 12),
          ...groupedResults[SearchResultType.company]!.asMap().entries.map((entry) {
            return AnimatedListItem(
              index: entry.key,
              child: _buildCompanyResult(entry.value, isDark),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskResult(SearchResult result, bool isDark) {
    final dateFormat = DateFormat('dd/MM HH:mm', 'pt_BR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ),
        title: Text(
          result.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: result.subtitle != null
            ? Text(
                result.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              )
            : null,
        trailing: result.date != null
            ? Text(
                dateFormat.format(result.date!),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              )
            : null,
        onTap: () {
          // Navegar para detalhes da tarefa
          context.push('/task/${result.id}');
        },
      ),
    );
  }

  Widget _buildTransactionResult(SearchResult result, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.attach_money, color: AppColors.success, size: 20),
        ),
        title: Text(
          result.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: result.subtitle != null
            ? Text(
                result.subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              )
            : null,
        onTap: () {
          // Navegar para finanças
          context.push('/finance');
        },
      ),
    );
  }

  Widget _buildCompanyResult(SearchResult result, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.business, color: AppColors.info, size: 20),
        ),
        title: Text(
          result.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: result.subtitle != null
            ? Text(
                result.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              )
            : null,
        onTap: () {
          // Navegar para empresas
          context.go('/companies');
        },
      ),
    );
  }
}
