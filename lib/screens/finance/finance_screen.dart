import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/finance.dart';
import '../../providers/finance_providers.dart';
import '../../data/repositories/finance_repository.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final month = ref.watch(selectedMonthProvider);
    final income = ref.watch(monthIncomeProvider);
    final expense = ref.watch(monthExpenseProvider);
    final balance = ref.watch(monthBalanceProvider);
    final categories = ref.watch(expensesByCategoryProvider);
    final allCategories = ref.watch(allCategoriesProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.finance, style: theme.textTheme.headlineLarge)),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(month.year, month.month - 1);
              },
            ),
            Text(
              l10n.monthName(month.month),
              style: theme.textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(month.year, month.month + 1);
              },
            ),
          ],
        ),
        const Gap(20),

        // Balance card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(l10n.balance, style: theme.textTheme.bodyMedium),
                const Gap(8),
                Text(
                  '${balance.toStringAsFixed(0)} ₽',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: balance >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: _FinanceMiniCard(
                        label: l10n.income,
                        amount: income,
                        color: AppColors.income,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: _FinanceMiniCard(
                        label: l10n.expense,
                        amount: expense,
                        color: AppColors.expense,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Gap(16),

        // Expense chart
        if (categories.isNotEmpty) ...[
          Text(l10n.expense, style: theme.textTheme.titleLarge),
          const Gap(12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(categories, allCategories),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const Gap(16),
                  _buildLegend(categories, allCategories),
                ],
              ),
            ),
          ),
          const Gap(16),
        ],

        // Quick actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAddTransactionDialog(context, ref, l10n, TransactionType.income),
                icon: const Icon(Icons.add, color: AppColors.income),
                label: Text(l10n.income),
              ),
            ),
            const Gap(12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAddTransactionDialog(context, ref, l10n, TransactionType.expense),
                icon: const Icon(Icons.add, color: AppColors.expense),
                label: Text(l10n.expense),
              ),
            ),
          ],
        ),
        const Gap(12),

        // Recent transactions
        Text(l10n.total, style: theme.textTheme.titleLarge),
        const Gap(8),
        ...ref.watch(monthTransactionsProvider).take(10).map((t) {
          final cat = ref.read(financeRepositoryProvider).getCategoryById(t.categoryId);
          return Card(
            margin: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              leading: Text(cat?.icon ?? '📁', style: const TextStyle(fontSize: 24)),
              title: Text(cat?.name ?? t.categoryId),
              subtitle: t.note != null ? Text(t.note!) : null,
              trailing: Text(
                '${t.type == TransactionType.income ? '+' : '-'}${t.amount.toStringAsFixed(0)} ₽',
                style: TextStyle(
                  color: t.type == TransactionType.income ? AppColors.income : AppColors.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  static const _categoryColors = [
    Color(0xFFFFE066),
    Color(0xFF4ECDC4),
    Color(0xFFFF6B6B),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFD4A574),
    Color(0xFFFFA07A),
    Color(0xFF98D8C8),
    Color(0xFFF7DC6F),
    Color(0xFFBB8FCE),
  ];

  Color _colorForCategoryId(String categoryId, int index) {
    final hash = categoryId.hashCode;
    return _categoryColors[hash.abs() % _categoryColors.length];
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> categories,
    List<Category> allCategories,
  ) {
    final total = categories.values.fold(0.0, (s, v) => s + v);
    int i = 0;
    return categories.entries.map((e) {
      final percent = total > 0 ? (e.value / total * 100) : 0.0;
      final color = _colorForCategoryId(e.key, i);
      i++;
      return PieChartSectionData(
        value: e.value,
        title: '${percent.toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildLegend(
    Map<String, double> categories,
    List<Category> allCategories,
  ) {
    final total = categories.values.fold(0.0, (s, v) => s + v);
    final catMap = {for (final c in allCategories) c.id: c};
    int i = 0;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categories.entries.map((e) {
        final cat = catMap[e.key];
        final color = _colorForCategoryId(e.key, i);
        final percent = total > 0 ? (e.value / total * 100) : 0.0;
        i++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Gap(4),
            Text(
              '${cat?.icon ?? ''} ${cat?.name ?? e.key} ${percent.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showAddTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TransactionType type,
  ) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String? selectedCategoryId;
    final categories = ref.read(
      type == TransactionType.income ? incomeCategoriesProvider : expenseCategoriesProvider,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type == TransactionType.income ? l10n.income : l10n.expense,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const Gap(16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: '0'),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const Gap(12),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                decoration: InputDecoration(hintText: l10n.category),
                items: categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.icon} ${c.name}'),
                )).toList(),
                onChanged: (v) => setModalState(() => selectedCategoryId = v),
              ),
              const Gap(12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(hintText: l10n.note),
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || selectedCategoryId == null) return;
                    final transaction = Transaction(
                      id: FinanceRepository.generateId(),
                      amount: amount,
                      categoryId: selectedCategoryId!,
                      type: type,
                      date: DateTime.now(),
                      note: noteController.text.isEmpty ? null : noteController.text,
                    );
                    await ref.read(financeRepositoryProvider).addTransaction(transaction);
                    ref.invalidate(monthTransactionsProvider);
                    ref.invalidate(monthIncomeProvider);
                    ref.invalidate(monthExpenseProvider);
                    ref.invalidate(monthBalanceProvider);
                    ref.invalidate(expensesByCategoryProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.save),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceMiniCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _FinanceMiniCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const Gap(4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const Gap(4),
          Text(
            '${amount.toStringAsFixed(0)} ₽',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
