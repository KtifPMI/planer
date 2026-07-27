import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/finance.dart';
import '../../providers/finance_providers.dart';
import '../../data/repositories/finance_repository.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final debts = ref.watch(allDebtsProvider);
    final totalDebt = ref.watch(totalDebtProvider);
    final totalPaid = ref.watch(totalPaidProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debts)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(l10n.total, style: theme.textTheme.bodyMedium),
                  const Gap(8),
                  Text(
                    '${totalDebt.toStringAsFixed(0)} ₽',
                    style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.debt),
                  ),
                  const Gap(4),
                  Text(
                    '${l10n.completed}: ${totalPaid.toStringAsFixed(0)} ₽',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),
          ...debts.map((debt) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (debt.isPaidOff ? AppColors.success : AppColors.debt).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  debt.isPaidOff ? Icons.check_circle : Icons.credit_card,
                  color: debt.isPaidOff ? AppColors.success : AppColors.debt,
                ),
              ),
              title: Text(debt.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(8),
                  LinearProgressIndicator(
                    value: debt.progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.debt.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(
                      debt.isPaidOff ? AppColors.success : AppColors.debt,
                    ),
                    minHeight: 4,
                  ),
                  const Gap(4),
                  Text(
                    '${debt.paidAmount.toStringAsFixed(0)} / ${debt.totalAmount.toStringAsFixed(0)} ₽ '
                    '(${(debt.progress * 100).toStringAsFixed(0)}%)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (_) => [
                   PopupMenuItem(value: 'pay', child: Text(AppLocalizations.of(context).pay)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                ],
                onSelected: (v) async {
                  if (v == 'delete') {
                    await ref.read(financeRepositoryProvider).deleteDebt(debt.id);
                    ref.invalidate(allDebtsProvider);
                  } else if (v == 'pay') {
                    _showPayDialog(context, ref, l10n, debt);
                  }
                },
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context, ref, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final rateController = TextEditingController(text: '0');
    final paymentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.add, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: nameController, decoration: InputDecoration(hintText: l10n.name), autofocus: true),
            const Gap(12),
            TextField(controller: amountController, decoration: const InputDecoration(hintText: 'Сумма долга'), keyboardType: TextInputType.number),
            const Gap(12),
            TextField(controller: rateController, decoration: const InputDecoration(hintText: 'Ставка %'), keyboardType: TextInputType.number),
            const Gap(12),
            TextField(controller: paymentController, decoration: const InputDecoration(hintText: 'Мин. платёж'), keyboardType: TextInputType.number),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (nameController.text.isEmpty || amount == null) return;
                  final debt = Debt(
                    id: FinanceRepository.generateId(),
                    name: nameController.text,
                    totalAmount: amount,
                    interestRate: double.tryParse(rateController.text) ?? 0,
                    minPayment: double.tryParse(paymentController.text) ?? 0,
                  );
                  await ref.read(financeRepositoryProvider).addDebt(debt);
                  ref.invalidate(allDebtsProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, Debt debt) {
    final controller = TextEditingController(text: debt.minPayment.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Оплата: ${debt.name}', style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: controller, decoration: const InputDecoration(hintText: '0 ₽'), keyboardType: TextInputType.number, autofocus: true),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(controller.text);
                  if (amount == null || amount <= 0) return;
                  debt.paidAmount += amount;
                  if (debt.isPaidOff) debt.status = 'paid';
                  await debt.save();
                  ref.invalidate(allDebtsProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}
