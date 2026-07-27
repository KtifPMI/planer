import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/nutrition.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/services/food_api_service.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/recipe_providers.dart';

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
    final targets = ref.watch(nutritionTargetsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.nutrition, style: theme.textTheme.headlineLarge),
        const Gap(8),
        _buildDateSelector(context, ref, l10n, date),
        const Gap(12),
        _buildTargetsCard(context, ref, l10n, targets, totals),
        const Gap(12),

        _buildMealSection(context, ref, l10n, MealType.breakfast, '🌅', l10n.breakfast),
        _buildMealSection(context, ref, l10n, MealType.secondBreakfast, '🥐', l10n.secondBreakfast),
        _buildMealSection(context, ref, l10n, MealType.lunch, '☀️', l10n.lunch),
        _buildMealSection(context, ref, l10n, MealType.afternoonSnack, '🧁', l10n.afternoonSnack),
        _buildMealSection(context, ref, l10n, MealType.dinner, '🌙', l10n.dinner),
        _buildMealSection(context, ref, l10n, MealType.snack, '🍪', l10n.snack),
        _buildMealSection(context, ref, l10n, MealType.eveningSnack, '🍵', l10n.eveningSnack),

        const Gap(8),
        _buildRecipesSection(context, ref, l10n),
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

  Widget _buildTargetsCard(BuildContext context, WidgetRef ref, AppLocalizations l10n, NutritionTargets targets, Map<String, double> totals) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTargetsDialog(context, ref, l10n, targets),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '${totals['calories']!.toStringAsFixed(0)} / ${targets.calories.toStringAsFixed(0)} ккал',
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
              _buildProgressRow('Б', totals['protein']!, targets.protein, const Color(0xFFFF6B6B), l10n),
              const Gap(8),
              _buildProgressRow('Ж', totals['fat']!, targets.fat, const Color(0xFFFFE066), l10n),
              const Gap(8),
              _buildProgressRow('У', totals['carbs']!, targets.carbs, const Color(0xFF4ECDC4), l10n),
              const Gap(8),
              Text(
                l10n.tapToEdit,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double current, double target, Color color, AppLocalizations l10n) {
    final pct = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final exceeded = target > 0 && current > target;
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(label, style: TextStyle(color: exceeded ? Colors.red : color, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(exceeded ? Colors.red : color),
              minHeight: 8,
            ),
          ),
        ),
        const Gap(8),
        SizedBox(
          width: 90,
          child: Text(
            '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} г',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: exceeded ? Colors.red : null),
          ),
        ),
      ],
    );
  }

  void _showTargetsDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, NutritionTargets targets) {
    final calCtrl = TextEditingController(text: targets.calories.toStringAsFixed(0));
    final protCtrl = TextEditingController(text: targets.protein.toStringAsFixed(0));
    final fatCtrl = TextEditingController(text: targets.fat.toStringAsFixed(0));
    final carbsCtrl = TextEditingController(text: targets.carbs.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nutritionTargets),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'ккал / день')),
            const Gap(8),
            TextField(controller: protCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Б (г)')),
            const Gap(8),
            TextField(controller: fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ж (г)')),
            const Gap(8),
            TextField(controller: carbsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'У (г)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final newTargets = NutritionTargets(
                calories: double.tryParse(calCtrl.text) ?? targets.calories,
                protein: double.tryParse(protCtrl.text) ?? targets.protein,
                fat: double.tryParse(fatCtrl.text) ?? targets.fat,
                carbs: double.tryParse(carbsCtrl.text) ?? targets.carbs,
              );
              saveNutritionTargets(ref, newTargets);
              Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.noEntries, style: const TextStyle(color: Colors.grey)),
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

  void _showAddRecipeAsMealDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, Recipe recipe) {
    final gramsController = TextEditingController(text: recipe.totalGrams.toStringAsFixed(0));

    MealType selectedMeal = MealType.breakfast;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final g = double.tryParse(gramsController.text) ?? recipe.totalGrams;
          final f = recipe.totalGrams > 0 ? g / recipe.totalGrams : 1;
          return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.name, style: Theme.of(ctx).textTheme.titleLarge),
              const Gap(12),
              TextField(
                controller: gramsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: l10n.portionWeight, suffixText: 'г'),
                onChanged: (_) => setSheetState(() {}),
              ),
              const Gap(8),
              Text(
                '${(recipe.sumCalories * f).toStringAsFixed(0)} ккал · '
                'Б${(recipe.sumProtein * f).toStringAsFixed(0)} '
                'Ж${(recipe.sumFat * f).toStringAsFixed(0)} '
                'У${(recipe.sumCarbs * f).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Gap(12),
              DropdownButtonFormField<MealType>(
                value: selectedMeal,
                isExpanded: true,
                items: MealType.values.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(_mealTypeName(m, l10n)),
                )).toList(),
                onChanged: (v) => setSheetState(() => selectedMeal = v ?? selectedMeal),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final grams = double.tryParse(gramsController.text) ?? recipe.totalGrams;
                    final factor = recipe.totalGrams > 0 ? grams / recipe.totalGrams : 1;
                    final date = ref.read(selectedNutritionDateProvider);

                    final entry = MealEntry(
                      id: NutritionRepository.generateId(),
                      foodName: recipe.name,
                      mealType: selectedMeal,
                      grams: grams,
                      calories: recipe.sumCalories * factor,
                      protein: recipe.sumProtein * factor,
                      fat: recipe.sumFat * factor,
                      carbs: recipe.sumCarbs * factor,
                      date: DateTime(date.year, date.month, date.day),
                    );

                    await ref.read(nutritionRepositoryProvider).addEntry(entry);
                    ref.invalidate(todayMealEntriesProvider);
                    ref.invalidate(todayNutritionTotalsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.save),
                ),
              ),
              const Gap(20),
            ],
          ),
          );
        },
      ),
    );
  }

  String _mealTypeName(MealType m, AppLocalizations l10n) {
    switch (m) {
      case MealType.breakfast: return l10n.breakfast;
      case MealType.secondBreakfast: return l10n.secondBreakfast;
      case MealType.lunch: return l10n.lunch;
      case MealType.afternoonSnack: return l10n.afternoonSnack;
      case MealType.dinner: return l10n.dinner;
      case MealType.snack: return l10n.snack;
      case MealType.eveningSnack: return l10n.eveningSnack;
    }
  }

  Widget _buildRecipesSection(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final recipes = ref.watch(recipesListProvider);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Text('📖', style: TextStyle(fontSize: 24)),
          title: Text(l10n.recipes, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Text(
            '${recipes.length}',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
          children: [
            if (recipes.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.noRecipes, style: const TextStyle(color: Colors.grey)),
                )
            else
              ...recipes.map((r) => ListTile(
                    title: Text(r.name),
                    subtitle: Text(
                      '${r.totalGrams.toStringAsFixed(0)} г · ${r.sumCalories.toStringAsFixed(0)} ккал · Б${r.sumProtein.toStringAsFixed(0)} Ж${r.sumFat.toStringAsFixed(0)} У${r.sumCarbs.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restaurant, size: 18),
                          tooltip: l10n.addFood,
                          onPressed: () => _showAddRecipeAsMealDialog(context, ref, l10n, r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () async {
                            await ref.read(recipeRepositoryProvider).delete(r.id);
                            refreshRecipes(ref);
                          },
                        ),
                      ],
                    ),
                  )),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(l10n.newRecipe),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
                );
                refreshRecipes(ref);
              },
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

  Recipe? _selectedRecipe;

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = ref.watch(todayNutritionTotalsProvider);
    final targets = ref.watch(nutritionTargetsProvider);

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

            _buildMiniProgress(totals, targets, l10n),
            const Gap(12),

            _buildRecipeSelector(context, ref, l10n),
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
                if (v.isNotEmpty && _selectedRecipe != null) {
                  setState(() => _selectedRecipe = null);
                }
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
              decoration: InputDecoration(hintText: l10n.gramsHint),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {});
                if (_selectedRecipe != null) _recalcFromRecipe();
              },
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                     decoration: InputDecoration(hintText: l10n.caloriesHint),
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
            const Gap(12),
            _buildEntryPreview(totals, targets, l10n),
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

  Widget _buildMiniProgress(Map<String, double> totals, NutritionTargets targets, AppLocalizations l10n) {
    final entryCal = double.tryParse(_caloriesController.text) ?? 0;
    final entryProt = double.tryParse(_proteinController.text) ?? 0;
    final entryFat = double.tryParse(_fatController.text) ?? 0;
    final entryCarbs = double.tryParse(_carbsController.text) ?? 0;

    return Column(
      children: [
        _buildMiniRow(l10n.caloriesShort, totals['calories']! + entryCal, targets.calories, const Color(0xFF9B59B6)),
        _buildMiniRow('Б', totals['protein']! + entryProt, targets.protein, const Color(0xFFFF6B6B)),
        _buildMiniRow('Ж', totals['fat']! + entryFat, targets.fat, const Color(0xFFFFE066)),
        _buildMiniRow('У', totals['carbs']! + entryCarbs, targets.carbs, const Color(0xFF4ECDC4)),
      ],
    );
  }

  Widget _buildMiniRow(String label, double current, double target, Color color) {
    final pct = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(pct > 1.0 ? Colors.red : color),
                minHeight: 6,
              ),
            ),
          ),
          const Gap(6),
          SizedBox(
            width: 72,
            child: Text(
              '${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: pct > 1.0 ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryPreview(Map<String, double> totals, NutritionTargets targets, AppLocalizations l10n) {
    final grams = double.tryParse(_gramsController.text) ?? 100;
    final cal = double.tryParse(_caloriesController.text) ?? 0;
    final prot = double.tryParse(_proteinController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;

    if (cal == 0 && prot == 0 && fat == 0 && carbs == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPreviewChip('${cal.toStringAsFixed(0)} ккал', const Color(0xFF9B59B6)),
          _buildPreviewChip('Б ${prot.toStringAsFixed(1)}', const Color(0xFFFF6B6B)),
          _buildPreviewChip('Ж ${fat.toStringAsFixed(1)}', const Color(0xFFFFE066)),
          _buildPreviewChip('У ${carbs.toStringAsFixed(1)}', const Color(0xFF4ECDC4)),
        ],
      ),
    );
  }

  Widget _buildPreviewChip(String text, Color color) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color));
  }

  Widget _buildRecipeSelector(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final recipes = ref.watch(recipesListProvider);
    if (recipes.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<Recipe>(
            value: _selectedRecipe,
            hint: Text(l10n.selectRecipe),
            isExpanded: true,
            items: recipes.map((r) => DropdownMenuItem(
              value: r,
              child: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (recipe) {
              setState(() {
                _selectedRecipe = recipe;
                if (recipe != null) {
                  _nameController.text = recipe.name;
                  final grams = double.tryParse(_gramsController.text) ?? 100;
                  final factor = recipe.totalGrams > 0 ? grams / recipe.totalGrams : grams / 100;
                  _caloriesController.text = (recipe.sumCalories * factor).toStringAsFixed(0);
                  _proteinController.text = (recipe.sumProtein * factor).toStringAsFixed(1);
                  _fatController.text = (recipe.sumFat * factor).toStringAsFixed(1);
                  _carbsController.text = (recipe.sumCarbs * factor).toStringAsFixed(1);
                }
              });
            },
          ),
        ),
        if (_selectedRecipe != null) ...[
          const Gap(8),
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              setState(() {
                _selectedRecipe = null;
                _nameController.clear();
                _caloriesController.clear();
                _proteinController.clear();
                _fatController.clear();
                _carbsController.clear();
              });
            },
          ),
        ],
      ],
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
    setState(() => _selectedRecipe = null);
  }

  void _recalcFromRecipe() {
    final recipe = _selectedRecipe;
    if (recipe == null) return;
    final grams = double.tryParse(_gramsController.text) ?? 100;
    final factor = recipe.totalGrams > 0 ? grams / recipe.totalGrams : grams / 100;
    _caloriesController.text = (recipe.sumCalories * factor).toStringAsFixed(0);
    _proteinController.text = (recipe.sumProtein * factor).toStringAsFixed(1);
    _fatController.text = (recipe.sumFat * factor).toStringAsFixed(1);
    _carbsController.text = (recipe.sumCarbs * factor).toStringAsFixed(1);
  }

  void _scanBarcode(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
    );
    if (result == null || !mounted) return;

    try {
      final food = await FoodApiService.searchByBarcode(result);
      if (food != null && mounted) {
        _fillFromFood(food);
      }
    } on FoodApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.isNotFound
                ? AppLocalizations.of(context).productNotFound
                : e.message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
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

    final date = ref.read(selectedNutritionDateProvider);

    final entry = MealEntry(
      id: NutritionRepository.generateId(),
      foodName: name,
      mealType: widget.mealType,
      grams: grams,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      date: DateTime(date.year, date.month, date.day),
    );

    await ref.read(nutritionRepositoryProvider).addEntry(entry);
    widget.onFoodAdded();
    if (mounted) Navigator.pop(context);
  }
}

class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _nameController = TextEditingController();
  final _totalGramsController = TextEditingController();
  final _searchController = TextEditingController();
  final List<RecipeIngredient> _ingredients = [];

  bool _showCustomFoodForm = false;
  final _cfNameController = TextEditingController();
  final _cfCalController = TextEditingController();
  final _cfProtController = TextEditingController();
  final _cfFatController = TextEditingController();
  final _cfCarbsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _totalGramsController.dispose();
    _searchController.dispose();
    _cfNameController.dispose();
    _cfCalController.dispose();
    _cfProtController.dispose();
    _cfFatController.dispose();
    _cfCarbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final totalCal = _ingredients.fold(0.0, (s, i) => s + i.calories);
    final totalProt = _ingredients.fold(0.0, (s, i) => s + i.protein);
    final totalFat = _ingredients.fold(0.0, (s, i) => s + i.fat);
    final totalCarbs = _ingredients.fold(0.0, (s, i) => s + i.carbs);
    final totalGrams = _ingredients.fold(0.0, (s, i) => s + i.grams);
    final targetGrams = double.tryParse(_totalGramsController.text) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newRecipe),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(hintText: '${l10n.name} рецепта')),
          const Gap(12),
          TextField(
            controller: _totalGramsController,
            decoration: InputDecoration(hintText: '${l10n.totalGrams} (${l10n.recipeTotalGramsHint})'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const Gap(16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchProduct,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (v) {
                    ref.read(foodSearchQueryProvider.notifier).state = v;
                  },
                ),
              ),
              const Gap(8),
              IconButton.filled(
                onPressed: () => setState(() => _showCustomFoodForm = !_showCustomFoodForm),
                icon: Icon(_showCustomFoodForm ? Icons.close : Icons.add),
                tooltip: l10n.createCustomFood,
              ),
            ],
          ),
          const Gap(8),

          if (_showCustomFoodForm) _buildCustomFoodForm(l10n),

          ref.watch(foodSearchResultsProvider).when(
            data: (results) {
              if (results.isEmpty || _searchController.text.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 180,
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
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () => _addIngredientFromFood(food),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Gap(16),

          if (_ingredients.isNotEmpty) ...[
            Text('${l10n.ingredients} (${_ingredients.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Gap(8),
            ..._ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final ing = entry.value;
              return Card(
                child: ListTile(
                  dense: true,
                  title: Text(ing.foodName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${ing.grams.toStringAsFixed(0)} г · ${ing.calories.toStringAsFixed(0)} ккал',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _ingredients.removeAt(i)),
                  ),
                ),
              );
            }),
            const Divider(),
            _buildRecipeSummary(totalCal, totalProt, totalFat, totalCarbs, totalGrams, targetGrams),
          ] else
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  l10n.addIngredientsHint,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomFoodForm(AppLocalizations l10n) {
    return Card(
      color: AppColors.primary.withOpacity(0.06),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.createCustomFood, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Gap(8),
            TextField(controller: _cfNameController, decoration: InputDecoration(hintText: l10n.foodName, isDense: true)),
            const Gap(8),
            Row(
              children: [
                Expanded(child: TextField(controller: _cfCalController, decoration: const InputDecoration(hintText: 'Ккал/100г', isDense: true), keyboardType: TextInputType.number)),
                const Gap(6),
                Expanded(child: TextField(controller: _cfProtController, decoration: const InputDecoration(hintText: 'Б', isDense: true), keyboardType: TextInputType.number)),
                const Gap(6),
                Expanded(child: TextField(controller: _cfFatController, decoration: const InputDecoration(hintText: 'Ж', isDense: true), keyboardType: TextInputType.number)),
                const Gap(6),
                Expanded(child: TextField(controller: _cfCarbsController, decoration: const InputDecoration(hintText: 'У', isDense: true), keyboardType: TextInputType.number)),
              ],
            ),
            const Gap(8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _saveCustomFood,
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCustomFood() async {
    final name = _cfNameController.text.trim();
    if (name.isEmpty) return;

    final food = FoodItem(
      name: name,
      calories: double.tryParse(_cfCalController.text) ?? 0,
      protein: double.tryParse(_cfProtController.text) ?? 0,
      fat: double.tryParse(_cfFatController.text) ?? 0,
      carbs: double.tryParse(_cfCarbsController.text) ?? 0,
    );

    await ref.read(customFoodRepositoryProvider).save(food);
    refreshCustomFoods(ref);

    _cfNameController.clear();
    _cfCalController.clear();
    _cfProtController.clear();
    _cfFatController.clear();
    _cfCarbsController.clear();
    setState(() => _showCustomFoodForm = false);

    _searchController.text = name;
    ref.read(foodSearchQueryProvider.notifier).state = name;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name ${AppLocalizations.of(context).saved}'), duration: const Duration(seconds: 2)),
      );
    }
  }

  Widget _buildRecipeSummary(double cal, double prot, double fat, double carbs, double sumGrams, double targetGrams) {
    final factor = targetGrams > 0 && sumGrams > 0 ? targetGrams / sumGrams : 1.0;
    return Card(
      color: AppColors.primary.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Суммарно: ${sumGrams.toStringAsFixed(0)} г', style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('${cal.toStringAsFixed(0)} ккал', style: const TextStyle(fontSize: 13)),
                Text('Б ${prot.toStringAsFixed(1)}', style: const TextStyle(fontSize: 13)),
                Text('Ж ${fat.toStringAsFixed(1)}', style: const TextStyle(fontSize: 13)),
                Text('У ${carbs.toStringAsFixed(1)}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (targetGrams > 0 && (targetGrams - sumGrams).abs() > 1) ...[
              const Divider(),
              Text('На ${targetGrams.toStringAsFixed(0)} г:', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('${(cal * factor).toStringAsFixed(0)} ккал', style: const TextStyle(fontSize: 12)),
                  Text('Б ${(prot * factor).toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                  Text('Ж ${(fat * factor).toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                  Text('У ${(carbs * factor).toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addIngredientFromFood(FoodItem food) {
    final controller = TextEditingController(text: '100');
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.gramsHint, suffixText: 'г'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final grams = double.tryParse(controller.text) ?? 100;
              final factor = grams / 100;
              _searchController.clear();
              ref.read(foodSearchQueryProvider.notifier).state = '';
              _ingredients.add(RecipeIngredient(
                foodName: food.name,
                grams: grams,
                calories: food.calories * factor,
                protein: food.protein * factor,
                fat: food.fat * factor,
                carbs: food.carbs * factor,
                barcode: food.barcode,
              ));
              setState(() {});
              Navigator.pop(ctx);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _saveRecipe() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _ingredients.isEmpty) return;

    final recipe = Recipe(
      id: RecipeRepository.generateId(),
      name: name,
      ingredients: _ingredients,
      totalGrams: double.tryParse(_totalGramsController.text) ?? _ingredients.fold(0.0, (s, i) => s + i.grams),
    );

    await ref.read(recipeRepositoryProvider).save(recipe);
    refreshRecipes(ref);
    if (mounted) Navigator.pop(context);
  }
}

class _BarcodeScannerScreen extends StatelessWidget {
  const _BarcodeScannerScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.barcodeScanner)),
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
