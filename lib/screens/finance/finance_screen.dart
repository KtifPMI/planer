import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/finance.dart';
import '../../providers/finance_providers.dart';
import '../../data/repositories/finance_repository.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _showIncomeChart = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final month = ref.watch(selectedMonthProvider);
    final income = ref.watch(filteredIncomeProvider);
    final expense = ref.watch(filteredExpenseProvider);
    final balance = ref.watch(filteredBalanceProvider);
    final categories = ref.watch(filteredExpensesByCategoryProvider);
    final incomeCategories = ref.watch(filteredIncomeByCategoryProvider);
    final allCategories = ref.watch(allCategoriesProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final transactions = ref.watch(filteredTransactionsProvider);

    final chartCategories = _showIncomeChart ? incomeCategories : categories;

    final incomeTxs = transactions.where((t) => t.type == TransactionType.income).toList();
    final expenseTxs = transactions.where((t) => t.type == TransactionType.expense).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Title row with responsive title
        Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(l10n.finance, style: theme.textTheme.headlineLarge),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(month.year, month.month - 1);
                ref.read(selectedDayProvider.notifier).state = null;
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
                ref.read(selectedDayProvider.notifier).state = null;
              },
            ),
            const Gap(4),
            IconButton(
              icon: Icon(Icons.calendar_today, size: 20,
                color: selectedDay != null ? AppColors.primary : null),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDay ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  ref.read(selectedDayProvider.notifier).state = picked;
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(picked.year, picked.month);
                }
              },
            ),
            if (selectedDay != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  ref.read(selectedDayProvider.notifier).state = null;
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
                Text(selectedDay != null
                    ? '${selectedDay.day} ${l10n.monthName(selectedDay.month)}'
                    : l10n.balance,
                  style: theme.textTheme.bodyMedium),
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
                        isActive: _showIncomeChart && incomeCategories.isNotEmpty,
                        onTap: incomeCategories.isNotEmpty
                            ? () => setState(() => _showIncomeChart = true)
                            : null,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: _FinanceMiniCard(
                        label: l10n.expense,
                        amount: expense,
                        color: AppColors.expense,
                        icon: Icons.arrow_upward,
                        isActive: !_showIncomeChart && categories.isNotEmpty,
                        onTap: categories.isNotEmpty
                            ? () => setState(() => _showIncomeChart = false)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Gap(16),

        // Quick actions (above chart)
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
        const Gap(16),

        // Toggleable chart (no SegmentedButton)
        if (chartCategories.isNotEmpty) ...[
          Text(
            _showIncomeChart ? l10n.income : l10n.expense,
            style: theme.textTheme.titleLarge,
          ),
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
                        sections: _buildPieSections(chartCategories, allCategories),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const Gap(16),
                  _buildLegend(chartCategories, allCategories),
                ],
              ),
            ),
          ),
          const Gap(16),
        ],

        // Separate income / expense transaction lists
        if (incomeTxs.isNotEmpty) ...[
          Text(l10n.income, style: theme.textTheme.titleLarge),
          const Gap(8),
          ...incomeTxs.map((t) => _buildTransactionTile(context, ref, l10n, t)),
        ],
        if (expenseTxs.isNotEmpty) ...[
          const Gap(12),
          Text(l10n.expense, style: theme.textTheme.titleLarge),
          const Gap(8),
          ...expenseTxs.map((t) => _buildTransactionTile(context, ref, l10n, t)),
        ],
        if (incomeTxs.isEmpty && expenseTxs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(l10n.noData, style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              )),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context, WidgetRef ref, AppLocalizations l10n, Transaction t) {
    final cat = ref.read(financeRepositoryProvider).getCategoryById(t.categoryId);
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Text(cat?.icon ?? '📁', style: const TextStyle(fontSize: 24)),
        title: Text(cat?.name ?? t.categoryId),
        subtitle: t.note != null ? Text(t.note!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${t.type == TransactionType.income ? '+' : '-'}${t.amount.toStringAsFixed(0)} ₽',
              style: TextStyle(
                color: t.type == TransactionType.income ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  _showEditTransactionDialog(context, ref, l10n, t);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.confirmDelete),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(financeRepositoryProvider).deleteTransaction(t.id);
                    invalidateAllFinance(ref);
                  }
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
              ],
            ),
          ],
        ),
      ),
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
    return _categoryColors[index % _categoryColors.length];
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
                    invalidateAllFinance(ref);
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

  void _showEditTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Transaction t,
  ) {
    final amountController = TextEditingController(text: t.amount.toStringAsFixed(0));
    final noteController = TextEditingController(text: t.note ?? '');
    String selectedCategoryId = t.categoryId;
    final categories = ref.read(
      t.type == TransactionType.income ? incomeCategoriesProvider : expenseCategoriesProvider,
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
              Text(l10n.editTransaction, style: Theme.of(ctx).textTheme.titleLarge),
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
                onChanged: (v) => setModalState(() => selectedCategoryId = v!),
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
                    if (amount == null) return;
                    final updated = Transaction(
                      id: t.id,
                      amount: amount,
                      categoryId: selectedCategoryId,
                      type: t.type,
                      date: t.date,
                      note: noteController.text.isEmpty ? null : noteController.text,
                    );
                    await ref.read(financeRepositoryProvider).updateTransaction(updated);
                    invalidateAllFinance(ref);
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
  final VoidCallback? onTap;
  final bool isActive;

  const _FinanceMiniCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: color, width: 2) : null,
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
      ),
    );
  }
}
