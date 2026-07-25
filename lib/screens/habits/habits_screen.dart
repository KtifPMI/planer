import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';
import '../../providers/habit_providers.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _prevDay() => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
  void _nextDay() => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
  void _goToToday() => setState(() => _selectedDate = DateTime.now());

  bool get _isToday =>
      _selectedDate.year == DateTime.now().year &&
      _selectedDate.month == DateTime.now().month &&
      _selectedDate.day == DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final habits = ref.watch(habitsListProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildDateHeader(theme, l10n),
          const Divider(height: 1),
          Expanded(
            child: habits.isEmpty
                ? _buildEmpty(l10n, theme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: habits.length,
                    itemBuilder: (ctx, i) => _HabitCard(
                      habit: habits[i],
                      selectedDate: _selectedDate,
                      repo: ref.read(habitRepositoryProvider),
                      onRefresh: () => setState(() {}),
                      l10n: l10n,
                      theme: theme,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(context, ref, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme, AppLocalizations l10n) {
    final dayName = l10n.dayName(_selectedDate.weekday);
    final monthName = l10n.monthName(_selectedDate.month);
    final isToday = _isToday;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevDay),
          Expanded(
            child: GestureDetector(
              onTap: _isToday ? null : _goToToday,
              child: Column(
                children: [
                  Text(
                    '${_selectedDate.day} $monthName',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    isToday ? l10n.today : dayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isToday ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextDay),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const Gap(12),
          Text(l10n.noData, style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          )),
          const Gap(16),
          FilledButton.icon(
            onPressed: () => _showAddHabitSheet(context, ref, l10n),
            icon: const Icon(Icons.add),
            label: Text(l10n.addHabit),
          ),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref, AppLocalizations l10n, {Habit? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HabitEditSheet(
        existing: existing,
        l10n: l10n,
        onSave: () => ref.invalidate(habitsListProvider),
      ),
    );
  }
}

// --- Single habit card ---
class _HabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime selectedDate;
  final HabitRepository repo;
  final VoidCallback onRefresh;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _HabitCard({
    required this.habit,
    required this.selectedDate,
    required this.repo,
    required this.onRefresh,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final todayValue = repo.getValueForDate(habit.id, selectedDate);
    final now = DateTime.now();
    final monthlyTotal = repo.getMonthlyTotal(habit.id, now.year, now.month);
    final monthlyProgress = repo.getMonthlyProgress(habit.id, now.year, now.month, habit.monthlyTarget);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(habit.icon, style: const TextStyle(fontSize: 24)),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Gap(2),
                      Text(
                        '$monthlyTotal / ${habit.monthlyTarget.toInt()} ${habit.unit}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!habit.isBoolean) ...[
                  _QuickAddButton(
                    icon: Icons.add,
                    onTap: () {
                      final current = repo.getValueForDate(habit.id, selectedDate);
                      repo.setEntry(habit.id, selectedDate, current + 1);
                      onRefresh();
                    },
                  ),
                  const Gap(6),
                  _InlineValueInput(
                    habit: habit,
                    date: selectedDate,
                    initialValue: todayValue,
                    repo: repo,
                    onSaved: onRefresh,
                  ),
                ] else
                  _BooleanToggle(
                    habit: habit,
                    date: selectedDate,
                    value: todayValue,
                    repo: repo,
                    onSaved: onRefresh,
                  ),
              ],
            ),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: monthlyProgress.clamp(0.0, 1.0),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(
                  monthlyProgress >= 1.0 ? AppColors.success : AppColors.primary,
                ),
                minHeight: 4,
              ),
            ),
            const Gap(4),
            Row(
              children: [
                Text(
                  '${(monthlyProgress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: monthlyProgress >= 1.0 ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(habit.monthlyTarget - monthlyTotal).clamp(0, 9999).toInt()} ${habit.unit} ${l10n.remaining.toLowerCase()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const Gap(4),
                GestureDetector(
                  onTap: () => _showDetail(context),
                  child: Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HabitDetailSheet(habit: habit, repo: repo, l10n: l10n),
    );
  }
}

// --- Quick +1 button ---
class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: const Icon(Icons.add, size: 18, color: AppColors.primary),
      ),
    );
  }
}

// --- Inline number input ---
class _InlineValueInput extends StatefulWidget {
  final Habit habit;
  final DateTime date;
  final double initialValue;
  final HabitRepository repo;
  final VoidCallback onSaved;

  const _InlineValueInput({
    required this.habit,
    required this.date,
    required this.initialValue,
    required this.repo,
    required this.onSaved,
  });

  @override
  State<_InlineValueInput> createState() => _InlineValueInputState();
}

class _InlineValueInputState extends State<_InlineValueInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue > 0 ? widget.initialValue.toInt().toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant _InlineValueInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      final newText = widget.initialValue > 0 ? widget.initialValue.toInt().toString() : '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final val = double.tryParse(_controller.text) ?? 0;
    widget.repo.setEntry(widget.habit.id, widget.date, val);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 40,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onSubmitted: (_) => _save(),
        onTapOutside: (_) => _save(),
      ),
    );
  }
}

// --- Boolean toggle ---
class _BooleanToggle extends StatelessWidget {
  final Habit habit;
  final DateTime date;
  final double value;
  final HabitRepository repo;
  final VoidCallback onSaved;

  const _BooleanToggle({
    required this.habit,
    required this.date,
    required this.value,
    required this.repo,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final done = value > 0;
    return GestureDetector(
      onTap: () async {
        await repo.setEntry(habit.id, date, done ? 0 : 1);
        onSaved();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: done ? AppColors.habitCompleted.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done ? AppColors.habitCompleted : Theme.of(context).dividerColor,
            width: done ? 2 : 1,
          ),
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check, color: AppColors.habitCompleted, size: 22)
              : const Icon(Icons.circle_outlined, size: 22),
        ),
      ),
    );
  }
}

// --- Detail bottom sheet with calendar ---
class _HabitDetailSheet extends StatefulWidget {
  final Habit habit;
  final HabitRepository repo;
  final AppLocalizations l10n;

  const _HabitDetailSheet({required this.habit, required this.repo, required this.l10n});

  @override
  State<_HabitDetailSheet> createState() => _HabitDetailSheetState();
}

class _HabitDetailSheetState extends State<_HabitDetailSheet> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = widget.habit;
    final now = DateTime.now();
    final monthlyTotal = widget.repo.getMonthlyTotal(h.id, now.year, now.month);
    final monthlyProgress = widget.repo.getMonthlyProgress(h.id, now.year, now.month, h.monthlyTarget);
    final daysDone = widget.repo.getDaysCompletedInMonth(h.id, now.year, now.month);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Gap(16),
            Row(
              children: [
                Text(h.icon, style: const TextStyle(fontSize: 32)),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '${h.monthlyTarget.toInt()} ${h.unit} / ${widget.l10n.month.toLowerCase()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(label: widget.l10n.month, value: '${monthlyTotal.toInt()} ${h.unit}'),
                        _StatItem(label: widget.l10n.completed, value: '$daysDone дн.'),
                        _StatItem(
                          label: widget.l10n.progress,
                          value: '${(monthlyProgress * 100).toStringAsFixed(0)}%',
                          color: monthlyProgress >= 1.0 ? AppColors.success : AppColors.primary,
                        ),
                      ],
                    ),
                    const Gap(12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: monthlyProgress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(
                          monthlyProgress >= 1.0 ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            Text(widget.l10n.calendar, style: theme.textTheme.titleMedium),
            const Gap(8),
            _MonthCalendar(
              habit: h,
              repo: widget.repo,
              month: _month,
              l10n: widget.l10n,
              onMonthChanged: (m) => setState(() => _month = m),
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditSheet(context, h);
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(widget.l10n.edit),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(widget.l10n.delete),
                          content: Text('${widget.l10n.confirm}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(widget.l10n.cancel)),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(widget.l10n.delete, style: const TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await widget.repo.delete(h.id);
                        if (ctx.mounted) Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: Text(widget.l10n.delete, style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HabitEditSheet(
        existing: habit,
        l10n: widget.l10n,
        onSave: () {},
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// --- Month calendar grid ---
class _MonthCalendar extends StatelessWidget {
  final Habit habit;
  final HabitRepository repo;
  final DateTime month;
  final AppLocalizations l10n;
  final ValueChanged<DateTime> onMonthChanged;

  const _MonthCalendar({
    required this.habit,
    required this.repo,
    required this.month,
    required this.l10n,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;
    final today = DateTime.now();

    final cells = <Widget>[];
    for (final d in ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']) {
      cells.add(Center(
        child: Text(d, style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        )),
      ));
    }
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final value = repo.getValueForDate(habit.id, date);
      final hasValue = value > 0;
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

      cells.add(AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.habitCompleted.withOpacity(0.15)
              : isToday
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.normal,
                  color: hasValue ? AppColors.success : null,
                ),
              ),
              if (hasValue)
                Text(
                  habit.isBoolean ? '✓' : value.toInt().toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => onMonthChanged(DateTime(month.year, month.month - 1)),
            ),
            Text(
              '${l10n.monthName(month.month)} ${month.year}',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => onMonthChanged(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.0,
          children: cells,
        ),
      ],
    );
  }
}

// --- Add / Edit habit bottom sheet ---
class _HabitEditSheet extends StatefulWidget {
  final Habit? existing;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  const _HabitEditSheet({this.existing, required this.l10n, required this.onSave});

  @override
  State<_HabitEditSheet> createState() => _HabitEditSheetState();
}

class _HabitEditSheetState extends State<_HabitEditSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _unitCtrl;
  late String _icon;
  late bool _isBoolean;

  static const _icons = ['✅', '🏃', '💧', '📖', '🧘', '📵', '📝', '🗒', '⏰', '😴', '💪', '🍎', '🧠', '🎯', '💰', '🧘‍♂️', '🏋️', '🚴', '🎵', '🧹'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _targetCtrl = TextEditingController(text: e?.monthlyTarget.toInt().toString() ?? '20');
    _unitCtrl = TextEditingController(text: e?.unit ?? widget.l10n.unitDays);
    _icon = e?.icon ?? '✅';
    _isBoolean = e?.isBoolean ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? widget.l10n.edit : widget.l10n.addHabit, style: theme.textTheme.titleLarge),
            const Gap(16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(hintText: widget.l10n.habitName),
              autofocus: !isEdit,
            ),
            const Gap(12),
            Text('${widget.l10n.name}:', style: theme.textTheme.labelMedium),
            const Gap(6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _icons.map((icon) => GestureDetector(
                onTap: () => setState(() => _icon = icon),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _icon == icon ? AppColors.primary.withOpacity(0.2) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _icon == icon ? AppColors.primary : theme.dividerColor,
                      width: _icon == icon ? 2 : 1,
                    ),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
                ),
              )).toList(),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetCtrl,
                    decoration: InputDecoration(hintText: widget.l10n.targetPerMonth),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: TextField(
                    controller: _unitCtrl,
                    decoration: InputDecoration(hintText: widget.l10n.unit),
                  ),
                ),
              ],
            ),
            const Gap(12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.l10n.booleanHabit),
              subtitle: Text(
                'Да/Нет вместо числового значения',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              value: _isBoolean,
              onChanged: (v) => setState(() => _isBoolean = v),
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(widget.l10n.save),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final target = double.tryParse(_targetCtrl.text) ?? 20;
    final unit = _unitCtrl.text.trim().isEmpty ? widget.l10n.unitDays : _unitCtrl.text.trim();

    final repo = HabitRepository();
    if (widget.existing != null) {
      final updated = widget.existing!
        ..name = _nameCtrl.text.trim()
        ..icon = _icon
        ..monthlyTarget = target
        ..unit = unit
        ..isBoolean = _isBoolean;
      await updated.save();
    } else {
      final habit = Habit(
        id: HabitRepository.generateId(),
        name: _nameCtrl.text.trim(),
        icon: _icon,
        monthlyTarget: target,
        unit: unit,
        isBoolean: _isBoolean,
      );
      await repo.add(habit);
    }

    widget.onSave();

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
