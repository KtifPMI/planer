import 'package:hive/hive.dart';
import '../models/habit.dart';
import '../models/finance.dart';
import '../models/workout.dart';
import '../models/planner.dart';
import '../models/nutrition.dart';
import '../models/nutrition.g.dart';
import '../models/recipe.dart';
import '../models/recipe.g.dart';

class StorageService {
  static late Box<Habit> _habitsBox;
  static late Box<HabitEntry> _habitEntriesBox;
  static late Box<Transaction> _transactionsBox;
  static late Box<Category> _categoriesBox;
  static late Box<SavingsGoal> _savingsBox;
  static late Box<Debt> _debtsBox;
  static late Box<WorkoutSession> _workoutsBox;
  static late Box<ExerciseTemplate> _exerciseTemplatesBox;
  static late Box<WorkoutTemplate> _workoutTemplatesBox;
  static late Box<WeeklyPlan> _weeklyPlansBox;
  static late Box<MealEntry> _mealEntriesBox;
  static late Box<Recipe> _recipesBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    _registerAdapters();

    _habitsBox = await Hive.openBox<Habit>('habits');
    _habitEntriesBox = await Hive.openBox<HabitEntry>('habitEntries');
    _transactionsBox = await Hive.openBox<Transaction>('transactions');
    _categoriesBox = await Hive.openBox<Category>('categories');
    _savingsBox = await Hive.openBox<SavingsGoal>('savings');
    _debtsBox = await Hive.openBox<Debt>('debts');
    _workoutsBox = await Hive.openBox<WorkoutSession>('workouts');
    _exerciseTemplatesBox = await Hive.openBox<ExerciseTemplate>('exerciseTemplates');
    _workoutTemplatesBox = await Hive.openBox<WorkoutTemplate>('workoutTemplates');
    _weeklyPlansBox = await Hive.openBox<WeeklyPlan>('weeklyPlans');
    _mealEntriesBox = await Hive.openBox<MealEntry>('mealEntries');
    _recipesBox = await Hive.openBox<Recipe>('recipes');
    _settingsBox = await Hive.openBox('settings');

    await _seedDefaultCategories();
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(HabitAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HabitEntryAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TransactionTypeAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TransactionAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CategoryAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(SavingsGoalAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(DebtAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(WorkoutSessionAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(ExerciseLogAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(SetLogAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(ExerciseTemplateAdapter());
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(WorkoutTemplateAdapter());
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(WeeklyPlanAdapter());
    if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(WeekGoalAdapter());
    if (!Hive.isAdapterRegistered(14)) Hive.registerAdapter(DayPlanAdapter());
    if (!Hive.isAdapterRegistered(15)) Hive.registerAdapter(PlannerTaskAdapter());
    if (!Hive.isAdapterRegistered(16)) Hive.registerAdapter(TemplateExerciseAdapter());
    if (!Hive.isAdapterRegistered(17)) Hive.registerAdapter(MealTypeAdapter());
    if (!Hive.isAdapterRegistered(18)) Hive.registerAdapter(FoodItemAdapter());
    if (!Hive.isAdapterRegistered(19)) Hive.registerAdapter(MealEntryAdapter());
    if (!Hive.isAdapterRegistered(20)) Hive.registerAdapter(RecipeAdapter());
    if (!Hive.isAdapterRegistered(21)) Hive.registerAdapter(RecipeIngredientAdapter());
  }

  static Future<void> _seedDefaultCategories() async {
    if (_categoriesBox.isNotEmpty) return;

    final defaultIncomeCategories = [
      Category(id: 'salary', name: 'Зарплата', icon: '💰', type: TransactionType.income),
      Category(id: 'freelance', name: 'Фриланс', icon: '💻', type: TransactionType.income),
      Category(id: 'business', name: 'Бизнес', icon: '🏢', type: TransactionType.income),
      Category(id: 'passive', name: 'Пассивный доход', icon: '📈', type: TransactionType.income),
      Category(id: 'other_income', name: 'Прочий доход', icon: '💵', type: TransactionType.income),
    ];

    final defaultExpenseCategories = [
      Category(id: 'food', name: 'Продукты', icon: '🛒', type: TransactionType.expense),
      Category(id: 'housing', name: 'Жильё', icon: '🏠', type: TransactionType.expense),
      Category(id: 'transport', name: 'Транспорт', icon: '🚗', type: TransactionType.expense),
      Category(id: 'health', name: 'Здоровье', icon: '🏥', type: TransactionType.expense),
      Category(id: 'education', name: 'Обучение', icon: '📚', type: TransactionType.expense),
      Category(id: 'entertainment', name: 'Развлечения', icon: '🎮', type: TransactionType.expense),
      Category(id: 'clothes', name: 'Одежда', icon: '👔', type: TransactionType.expense),
      Category(id: 'utilities', name: 'Коммуналка', icon: '💡', type: TransactionType.expense),
      Category(id: 'communication', name: 'Связь', icon: '📱', type: TransactionType.expense),
      Category(id: 'debt_payment', name: 'Платежи по долгам', icon: '💳', type: TransactionType.expense),
      Category(id: 'other_expense', name: 'Прочее', icon: '📦', type: TransactionType.expense),
    ];

    for (final c in [...defaultIncomeCategories, ...defaultExpenseCategories]) {
      await _categoriesBox.put(c.id, c);
    }
  }

  static Box<Habit> get habitsBox => _habitsBox;
  static Box<HabitEntry> get habitEntriesBox => _habitEntriesBox;
  static Box<Transaction> get transactionsBox => _transactionsBox;
  static Box<Category> get categoriesBox => _categoriesBox;
  static Box<SavingsGoal> get savingsBox => _savingsBox;
  static Box<Debt> get debtsBox => _debtsBox;
  static Box<WorkoutSession> get workoutsBox => _workoutsBox;
  static Box<ExerciseTemplate> get exerciseTemplatesBox => _exerciseTemplatesBox;
  static Box<WorkoutTemplate> get workoutTemplatesBox => _workoutTemplatesBox;
  static Box<WeeklyPlan> get weeklyPlansBox => _weeklyPlansBox;
  static Box<MealEntry> get mealEntriesBox => _mealEntriesBox;
  static Box<Recipe> get recipesBox => _recipesBox;
  static Box get settingsBox => _settingsBox;
}
