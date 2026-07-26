import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/nutrition.dart';
import '../../providers/nutrition_providers.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/services/food_api_service.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final totals = ref.watch(todayNutritionTotalsProvider);
    final date = ref.watch(selectedNutritionDateProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.nutrition, style: theme.textTheme.headlineLarge),
        const Gap(8),
        _buildDateSelector(context, ref, l10n, date),
        const Gap(16),

        _buildTotalsCard(context, l10n, totals),
        const Gap(16),

        _buildMealSection(context, ref, l10n, MealType.breakfast, '🌅', l10n.breakfast),
        _buildMealSection(context, ref, l10n, MealType.lunch, '☀️', l10n.lunch),
        _buildMealSection(context, ref, l10n, MealType.dinner, '🌙', l10n.dinner),
        _buildMealSection(context, ref, l10n, MealType.snack, '🍪', l10n.snack),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context, WidgetRef ref, AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            ref.read(selectedNutritionDateProvider.notifier).state =
                date.subtract(const Duration(days: 1));
          },
        ),
        Expanded(
          child: Text(
            _formatDate(date, l10n),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: date.isBefore(now)
              ? () {
                  ref.read(selectedNutritionDateProvider.notifier).state =
                      date.add(const Duration(days: 1));
                }
              : null,
        ),
      ],
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return l10n.today;
    if (d == today.subtract(const Duration(days: 1))) return l10n.yesterday;
    return '${date.day} ${l10n.monthName(date.month)}';
  }

  Widget _buildTotalsCard(BuildContext context, AppLocalizations l10n, Map<String, double> totals) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${totals['calories']!.toStringAsFixed(0)} ккал',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(4),
            Text(
              '${l10n.today.toLowerCase()}',
              style: theme.textTheme.bodySmall,
            ),
            const Gap(16),
            Row(
              children: [
                _NutrientBar(
                  label: 'Б',
                  value: totals['protein']!,
                  color: const Color(0xFFFF6B6B),
                ),
                const Gap(12),
                _NutrientBar(
                  label: 'Ж',
                  value: totals['fat']!,
                  color: const Color(0xFFFFE066),
                ),
                const Gap(12),
                _NutrientBar(
                  label: 'У',
                  value: totals['carbs']!,
                  color: const Color(0xFF4ECDC4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    MealType mealType,
    String icon,
    String title,
  ) {
    final entries = ref.watch(mealEntriesForTypeProvider(mealType));
    final totalCals = entries.fold(0.0, (s, e) => s + e.calories);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Text(icon, style: const TextStyle(fontSize: 24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Text(
            '${totalCals.toStringAsFixed(0)} ккал',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет записей', style: TextStyle(color: Colors.grey)),
              )
            else
              ...entries.map((e) => ListTile(
                    title: Text(e.foodName),
                    subtitle: Text('${e.grams.toStringAsFixed(0)} г'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${e.calories.toStringAsFixed(0)} ккал',
                          style: const TextStyle(fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () async {
                            await ref.read(nutritionRepositoryProvider).deleteEntry(e.id);
                            ref.invalidate(todayMealEntriesProvider);
                            ref.invalidate(todayNutritionTotalsProvider);
                          },
                        ),
                      ],
                    ),
                  )),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(l10n.addFood),
              onTap: () => _showAddFoodSheet(context, ref, l10n, mealType),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    MealType mealType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddFoodSheet(
        mealType: mealType,
        onFoodAdded: () {
          ref.invalidate(todayMealEntriesProvider);
          ref.invalidate(todayNutritionTotalsProvider);
        },
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _NutrientBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Gap(4),
            Text(
              '${value.toStringAsFixed(1)} г',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFoodSheet extends ConsumerStatefulWidget {
  final MealType mealType;
  final VoidCallback onFoodAdded;

  const _AddFoodSheet({required this.mealType, required this.onFoodAdded});

  @override
  ConsumerState<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<_AddFoodSheet> {
  final _nameController = TextEditingController();
  final _gramsController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.addFood, style: Theme.of(context).textTheme.titleLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => _scanBarcode(context),
                ),
              ],
            ),
            const Gap(12),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchProduct,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(foodSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() {});
                ref.read(foodSearchQueryProvider.notifier).state = v;
              },
            ),
            const Gap(8),

            ref.watch(foodSearchResultsProvider).when(
              data: (results) {
                if (results.isEmpty || _searchController.text.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (ctx, i) {
                      final food = results[i];
                      return ListTile(
                        dense: true,
                        title: Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          '${food.calories.toStringAsFixed(0)} ккал/100г · Б${food.protein.toStringAsFixed(0)} Ж${food.fat.toStringAsFixed(0)} У${food.carbs.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => _fillFromFood(food),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const Gap(12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: l10n.foodName),
            ),
            const Gap(12),
            TextField(
              controller: _gramsController,
              decoration: const InputDecoration(hintText: 'Граммы'),
              keyboardType: TextInputType.number,
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(hintText: 'Ккал'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    decoration: const InputDecoration(hintText: 'Б (г)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: TextField(
                    controller: _fatController,
                    decoration: const InputDecoration(hintText: 'Ж (г)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    decoration: const InputDecoration(hintText: 'У (г)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveEntry,
                child: Text(l10n.save),
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  void _fillFromFood(FoodItem food) {
    _nameController.text = food.name;
    final grams = double.tryParse(_gramsController.text) ?? 100;
    final factor = grams / 100;
    _caloriesController.text = (food.calories * factor).toStringAsFixed(0);
    _proteinController.text = (food.protein * factor).toStringAsFixed(1);
    _fatController.text = (food.fat * factor).toStringAsFixed(1);
    _carbsController.text = (food.carbs * factor).toStringAsFixed(1);
    _searchController.clear();
    ref.read(foodSearchQueryProvider.notifier).state = '';
    setState(() {});
  }

  void _scanBarcode(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
    );
    if (result == null || !mounted) return;

    final food = await FoodApiService.searchByBarcode(result);
    if (food != null && mounted) {
      _fillFromFood(food);
    }
  }

  void _saveEntry() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final grams = double.tryParse(_gramsController.text) ?? 100;
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;

    final entry = MealEntry(
      id: NutritionRepository.generateId(),
      foodName: name,
      mealType: widget.mealType,
      grams: grams,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      date: DateTime.now(),
    );

    await ref.read(nutritionRepositoryProvider).addEntry(entry);
    widget.onFoodAdded();
    if (mounted) Navigator.pop(context);
  }
}

class _BarcodeScannerScreen extends StatelessWidget {
  const _BarcodeScannerScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканирование штрихкода')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first.rawValue;
          if (barcode != null) {
            Navigator.pop(context, barcode);
          }
        },
      ),
    );
  }
}
