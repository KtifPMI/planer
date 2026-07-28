import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/finance.dart';
import '../../providers/finance_providers.dart';
import '../../data/repositories/finance_repository.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final savings = ref.watch(allSavingsProvider);
    final totalSaved = ref.watch(totalSavedProvider);
    final totalTarget = ref.watch(totalTargetProvider);
    final overallProgress = totalTarget > 0 ? totalSaved / totalTarget : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savings)),
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
                    '${totalSaved.toStringAsFixed(0)} / ${totalTarget.toStringAsFixed(0)} ₽',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const Gap(12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: overallProgress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.savings.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.savings),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),
          if (savings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.savings_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const Gap(12),
                    Text(l10n.noData, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
            )
          else
            ...savings.map((goal) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.savings.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.savings, color: AppColors.savings),
              ),
              title: Text(goal.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(8),
                  LinearProgressIndicator(
                    value: goal.progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.savings.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.savings),
                    minHeight: 4,
                  ),
                  const Gap(4),
                  Text(
                    '${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} ₽ '
                    '(${(goal.progress * 100).toStringAsFixed(0)}%)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.edit),
                  ),
                  PopupMenuItem(
                    value: 'add',
                    child: Text(l10n.add),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.delete),
                  ),
                ],
                onSelected: (v) async {
                  if (v == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.delete),
                        content: Text('${l10n.delete} "${goal.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(financeRepositoryProvider).deleteSavingsGoal(goal.id);
                      ref.invalidate(allSavingsProvider);
                    }
                  } else if (v == 'edit') {
                    _showEditSavingsDialog(context, ref, l10n, goal);
                  } else if (v == 'add') {
                    _showAddAmountDialog(context, ref, l10n, goal);
                  }
                },
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSavingsDialog(context, ref, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSavingsDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();

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
            Text(l10n.addGoal, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: nameController, decoration: InputDecoration(hintText: l10n.name), autofocus: true),
            const Gap(12),
            TextField(controller: targetController, decoration: const InputDecoration(hintText: '0 ₽'), keyboardType: TextInputType.number),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final target = double.tryParse(targetController.text);
                  if (nameController.text.isEmpty || target == null) return;
                  try {
                    final goal = SavingsGoal(
                      id: FinanceRepository.generateId(),
                      name: nameController.text,
                      targetAmount: target,
                    );
                    await ref.read(financeRepositoryProvider).addSavingsGoal(goal);
                    ref.invalidate(allSavingsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('${l10n.error}: $e')),
                      );
                    }
                  }
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

  void _showAddAmountDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, SavingsGoal goal) {
    final controller = TextEditingController();

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
            Text('${l10n.add} ${goal.name}', style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: controller, decoration: const InputDecoration(hintText: '0 ₽'), keyboardType: TextInputType.number, autofocus: true),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(controller.text);
                  if (amount == null) return;
                  try {
                    goal.currentAmount += amount;
                    await goal.save();
                    ref.invalidate(allSavingsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('${l10n.error}: $e')),
                      );
                    }
                  }
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

  void _showEditSavingsDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, SavingsGoal goal) {
    final nameController = TextEditingController(text: goal.name);
    final targetController = TextEditingController(text: goal.targetAmount.toStringAsFixed(0));

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
            Text(l10n.edit, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(16),
            TextField(controller: nameController, decoration: InputDecoration(hintText: l10n.name), autofocus: true),
            const Gap(12),
            TextField(controller: targetController, decoration: const InputDecoration(hintText: '0 ₽'), keyboardType: TextInputType.number),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final target = double.tryParse(targetController.text);
                  if (nameController.text.isEmpty || target == null) return;
                  goal.name = nameController.text;
                  goal.targetAmount = target;
                  await goal.save();
                  ref.invalidate(allSavingsProvider);
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
