import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _translations = {
    'ru': {
      'appTitle': 'Трекер',
      'dashboard': 'Главная',
      'habits': 'Привычки',
      'finance': 'Финансы',
      'workouts': 'Тренировки',
      'planner': 'Планер',
      'settings': 'Настройки',
      'language': 'Язык',
      'theme': 'Тема',
      'darkTheme': 'Тёмная тема',
      'lightTheme': 'Светлая тема',
      'today': 'Сегодня',
      'week': 'Неделя',
      'month': 'Месяц',
      'year': 'Год',
      'add': 'Добавить',
      'edit': 'Редактировать',
      'delete': 'Удалить',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'confirm': 'Подтвердить',
      'name': 'Название',
      'amount': 'Сумма',
      'date': 'Дата',
      'note': 'Заметка',
      'progress': 'Прогресс',
      'plan': 'План',
      'fact': 'Факт',
      'total': 'Итого',
      'balance': 'Баланс',
      'income': 'Доходы',
      'expense': 'Расходы',
      'savings': 'Накопления',
      'debts': 'Долги',
      'categories': 'Категории',
      'completed': 'Выполнено',
      'remaining': 'Осталось',
      'noData': 'Нет данных',
      'habitTracker': 'Трекер привычек',
      'addHabit': 'Добавить привычку',
      'habitName': 'Название привычки',
      'targetPerMonth': 'Цель в месяц',
      'financeTracker': 'Финансовый трекер',
      'addTransaction': 'Добавить транзакцию',
      'transactionType': 'Тип транзакции',
      'category': 'Категория',
      'workoutTracker': 'Тренировки',
      'addWorkout': 'Добавить тренировку',
      'exercise': 'Упражнение',
      'sets': 'Подходы',
      'reps': 'Повторения',
      'weight': 'Вес',
      'weeklyPlaner': 'Еженедельный планер',
      'goals': 'Цели',
      'tasks': 'Задачи',
      'notes': 'Заметки',
      'monday': 'Пн',
      'tuesday': 'Вт',
      'wednesday': 'Ср',
      'thursday': 'Чт',
      'friday': 'Пт',
      'saturday': 'Сб',
      'sunday': 'Вс',
      'january': 'Январь',
      'february': 'Февраль',
      'march': 'Март',
      'april': 'Апрель',
      'may': 'Май',
      'june': 'Июнь',
      'july': 'Июль',
      'august': 'Август',
      'september': 'Сентябрь',
      'october': 'Октябрь',
      'november': 'Ноябрь',
      'december': 'Декабрь',
      'addGoal': 'Добавить финансовую цель',
      'addTask': 'Добавить задачу',
      'weeklyGoals': 'Цели недели',
      'dayNotes': 'Заметки дня',
      'analytics': 'Аналитика',
      'totalTasks': 'Всего задач',
      'productiveDay': 'Продуктивный день',
      'about': 'О приложении',
      'unit': 'Ед. изм.',
      'unitTimes': 'раз',
      'unitPages': 'страниц',
      'unitMinutes': 'минут',
      'unitKm': 'км',
      'unitDays': 'дней',
      'todayValue': 'Сегодня',
      'monthlyProgress': 'Прогресс за месяц',
      'detail': 'Подробнее',
      'calendar': 'Календарь',
      'done': 'Готово',
      'addValue': 'Введите значение',
      'booleanHabit': 'Да / Нет',
      'workoutTemplates': 'Шаблоны тренировок',
      'addTemplate': 'Добавить шаблон',
      'editTemplate': 'Редактировать шаблон',
      'templateName': 'Название шаблона',
      'exercises': 'Упражнения',
      'addExercise': 'Добавить упражнение',
      'exerciseName': 'Название упражнения',
      'setsCount': 'Подходы',
      'repsCount': 'Повторения',
      'targetWeight': 'Вес (кг)',
      'dayOfWeek': 'День недели',
      'startWorkout': 'Начать тренировку',
      'todayWorkout': 'Тренировка дня',
      'noWorkoutToday': 'Нет тренировки на сегодня',
      'workoutSettings': 'Настройки тренировок',
      'activeWorkout': 'Активная тренировка',
      'finishWorkout': 'Завершить',
      'logSet': 'Записать подход',
      'checkUpdate': 'Проверить обновления',
      'updateAvailable': 'Доступно обновление',
      'noUpdate': 'У вас последняя версия',
      'currentVersion': 'Текущая версия',
      'newVersion': 'Новая версия',
      'download': 'Скачать',
      'changelog': 'Изменения',
      'checking': 'Проверка...',
      'nutrition': 'Питание',
      'breakfast': 'Завтрак',
      'lunch': 'Обед',
      'dinner': 'Ужин',
      'snack': 'Перекус',
      'secondBreakfast': 'Второй завтрак',
      'afternoonSnack': 'Полдник',
      'eveningSnack': 'Вечерний перекус',
      'addFood': 'Добавить продукт',
      'searchProduct': 'Поиск продукта...',
      'foodName': 'Название продукта',
      'yesterday': 'Вчера',
      'networkError': 'Нет подключения к интернету',
      'recipes': 'Рецепты',
      'newRecipe': 'Новый рецепт',
      'selectRecipe': 'Выбрать рецепт',
      'ingredients': 'Ингредиенты',
      'addIngredientsHint': 'Найдите продукт и нажмите +\nчтобы добавить ингредиент',
      'servings': 'Порций',
      'tapToEdit': 'Нажмите для редактирования',
      'nutritionTargets': 'Дневная норма',
    },
    'en': {
      'appTitle': 'Tracker',
      'dashboard': 'Home',
      'habits': 'Habits',
      'finance': 'Finance',
      'workouts': 'Workouts',
      'planner': 'Planner',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'darkTheme': 'Dark theme',
      'lightTheme': 'Light theme',
      'today': 'Today',
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'name': 'Name',
      'amount': 'Amount',
      'date': 'Date',
      'note': 'Note',
      'progress': 'Progress',
      'plan': 'Plan',
      'fact': 'Actual',
      'total': 'Total',
      'balance': 'Balance',
      'income': 'Income',
      'expense': 'Expenses',
      'savings': 'Savings',
      'debts': 'Debts',
      'categories': 'Categories',
      'completed': 'Completed',
      'remaining': 'Remaining',
      'noData': 'No data',
      'habitTracker': 'Habit Tracker',
      'addHabit': 'Add habit',
      'habitName': 'Habit name',
      'targetPerMonth': 'Target per month',
      'financeTracker': 'Finance Tracker',
      'addTransaction': 'Add transaction',
      'transactionType': 'Transaction type',
      'category': 'Category',
      'workoutTracker': 'Workouts',
      'addWorkout': 'Add workout',
      'exercise': 'Exercise',
      'sets': 'Sets',
      'reps': 'Reps',
      'weight': 'Weight',
      'weeklyPlaner': 'Weekly Planner',
      'goals': 'Goals',
      'tasks': 'Tasks',
      'notes': 'Notes',
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',
      'addGoal': 'Add financial goal',
      'addTask': 'Add task',
      'weeklyGoals': 'Weekly goals',
      'dayNotes': 'Day notes',
      'analytics': 'Analytics',
      'totalTasks': 'Total tasks',
      'productiveDay': 'Productive day',
      'about': 'About',
      'unit': 'Unit',
      'unitTimes': 'times',
      'unitPages': 'pages',
      'unitMinutes': 'minutes',
      'unitKm': 'km',
      'unitDays': 'days',
      'todayValue': 'Today',
      'monthlyProgress': 'Monthly progress',
      'detail': 'Details',
      'calendar': 'Calendar',
      'done': 'Done',
      'addValue': 'Enter value',
      'booleanHabit': 'Yes / No',
      'workoutTemplates': 'Workout Templates',
      'addTemplate': 'Add template',
      'editTemplate': 'Edit template',
      'templateName': 'Template name',
      'exercises': 'Exercises',
      'addExercise': 'Add exercise',
      'exerciseName': 'Exercise name',
      'setsCount': 'Sets',
      'repsCount': 'Reps',
      'targetWeight': 'Weight (kg)',
      'dayOfWeek': 'Day of week',
      'startWorkout': 'Start workout',
      'todayWorkout': 'Today\'s workout',
      'noWorkoutToday': 'No workout today',
      'workoutSettings': 'Workout settings',
      'activeWorkout': 'Active workout',
      'finishWorkout': 'Finish',
      'logSet': 'Log set',
      'checkUpdate': 'Check for updates',
      'updateAvailable': 'Update available',
      'noUpdate': 'You have the latest version',
      'currentVersion': 'Current version',
      'newVersion': 'New version',
      'download': 'Download',
      'changelog': 'Changelog',
      'checking': 'Checking...',
      'nutrition': 'Nutrition',
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',
      'secondBreakfast': 'Second breakfast',
      'afternoonSnack': 'Afternoon snack',
      'eveningSnack': 'Evening snack',
      'addFood': 'Add food',
      'searchProduct': 'Search product...',
      'foodName': 'Food name',
      'yesterday': 'Yesterday',
      'networkError': 'No internet connection',
      'recipes': 'Recipes',
      'newRecipe': 'New recipe',
      'selectRecipe': 'Select recipe',
      'ingredients': 'Ingredients',
      'addIngredientsHint': 'Search for a food item and tap +\nto add an ingredient',
      'servings': 'Servings',
      'tapToEdit': 'Tap to edit',
      'nutritionTargets': 'Daily targets',
    },
  };

  String _t(String key) => _translations[locale.languageCode]?[key] ?? key;

  String get appTitle => _t('appTitle');
  String get dashboard => _t('dashboard');
  String get habits => _t('habits');
  String get finance => _t('finance');
  String get workouts => _t('workouts');
  String get planner => _t('planner');
  String get settings => _t('settings');
  String get language => _t('language');
  String get theme => _t('theme');
  String get darkTheme => _t('darkTheme');
  String get lightTheme => _t('lightTheme');
  String get today => _t('today');
  String get week => _t('week');
  String get month => _t('month');
  String get year => _t('year');
  String get add => _t('add');
  String get edit => _t('edit');
  String get delete => _t('delete');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');
  String get name => _t('name');
  String get amount => _t('amount');
  String get date => _t('date');
  String get note => _t('note');
  String get progress => _t('progress');
  String get plan => _t('plan');
  String get fact => _t('fact');
  String get total => _t('total');
  String get balance => _t('balance');
  String get income => _t('income');
  String get expense => _t('expense');
  String get savings => _t('savings');
  String get debts => _t('debts');
  String get categories => _t('categories');
  String get completed => _t('completed');
  String get remaining => _t('remaining');
  String get noData => _t('noData');
  String get habitTracker => _t('habitTracker');
  String get addHabit => _t('addHabit');
  String get habitName => _t('habitName');
  String get targetPerMonth => _t('targetPerMonth');
  String get financeTracker => _t('financeTracker');
  String get addTransaction => _t('addTransaction');
  String get transactionType => _t('transactionType');
  String get category => _t('category');
  String get workoutTracker => _t('workoutTracker');
  String get addWorkout => _t('addWorkout');
  String get exercise => _t('exercise');
  String get sets => _t('sets');
  String get reps => _t('reps');
  String get weight => _t('weight');
  String get weeklyPlaner => _t('weeklyPlaner');
  String get goals => _t('goals');
  String get tasks => _t('tasks');
  String get notes => _t('notes');
  String get monday => _t('monday');
  String get tuesday => _t('tuesday');
  String get wednesday => _t('wednesday');
  String get thursday => _t('thursday');
  String get friday => _t('friday');
  String get saturday => _t('saturday');
  String get sunday => _t('sunday');
  String get addGoal => _t('addGoal');
  String get addTask => _t('addTask');
  String get weeklyGoals => _t('weeklyGoals');
  String get dayNotes => _t('dayNotes');
  String get analytics => _t('analytics');
  String get totalTasks => _t('totalTasks');
  String get productiveDay => _t('productiveDay');
  String get about => _t('about');
  String get unit => _t('unit');
  String get unitTimes => _t('unitTimes');
  String get unitPages => _t('unitPages');
  String get unitMinutes => _t('unitMinutes');
  String get unitKm => _t('unitKm');
  String get unitDays => _t('unitDays');
  String get todayValue => _t('todayValue');
  String get monthlyProgress => _t('monthlyProgress');
  String get detail => _t('detail');
  String get calendar => _t('calendar');
  String get done => _t('done');
  String get addValue => _t('addValue');
  String get booleanHabit => _t('booleanHabit');
  String get workoutTemplates => _t('workoutTemplates');
  String get addTemplate => _t('addTemplate');
  String get editTemplate => _t('editTemplate');
  String get templateName => _t('templateName');
  String get exercises => _t('exercises');
  String get addExercise => _t('addExercise');
  String get exerciseName => _t('exerciseName');
  String get setsCount => _t('setsCount');
  String get repsCount => _t('repsCount');
  String get targetWeight => _t('targetWeight');
  String get dayOfWeek => _t('dayOfWeek');
  String get startWorkout => _t('startWorkout');
  String get todayWorkout => _t('todayWorkout');
  String get noWorkoutToday => _t('noWorkoutToday');
  String get workoutSettings => _t('workoutSettings');
  String get activeWorkout => _t('activeWorkout');
  String get finishWorkout => _t('finishWorkout');
  String get logSet => _t('logSet');
  String get checkUpdate => _t('checkUpdate');
  String get updateAvailable => _t('updateAvailable');
  String get noUpdate => _t('noUpdate');
  String get currentVersion => _t('currentVersion');
  String get newVersion => _t('newVersion');
  String get download => _t('download');
  String get changelog => _t('changelog');
  String get checking => _t('checking');
  String get nutrition => _t('nutrition');
  String get breakfast => _t('breakfast');
  String get lunch => _t('lunch');
  String get dinner => _t('dinner');
  String get snack => _t('snack');
  String get secondBreakfast => _t('secondBreakfast');
  String get afternoonSnack => _t('afternoonSnack');
  String get eveningSnack => _t('eveningSnack');
  String get addFood => _t('addFood');
  String get searchProduct => _t('searchProduct');
  String get foodName => _t('foodName');
  String get yesterday => _t('yesterday');
  String get networkError => _t('networkError');
  String get recipes => _t('recipes');
  String get newRecipe => _t('newRecipe');
  String get selectRecipe => _t('selectRecipe');
  String get ingredients => _t('ingredients');
  String get addIngredientsHint => _t('addIngredientsHint');
  String get servings => _t('servings');
  String get tapToEdit => _t('tapToEdit');
  String get nutritionTargets => _t('nutritionTargets');

  String monthName(int month) {
    const months = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december',
    ];
    return _t(months[month - 1]);
  }

  String dayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return _t(days[weekday - 1]);
  }

  String dayNameFull(int weekday) {
    const days = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье',
    ];
    const daysEn = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return locale.languageCode == 'ru' ? days[weekday - 1] : daysEn[weekday - 1];
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
