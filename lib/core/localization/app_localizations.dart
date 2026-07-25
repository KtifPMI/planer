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
      'addGoal': 'Добавить цель',
      'addTask': 'Добавить задачу',
      'weeklyGoals': 'Цели недели',
      'dayNotes': 'Заметки дня',
      'analytics': 'Аналитика',
      'totalTasks': 'Всего задач',
      'productiveDay': 'Продуктивный день',
      'about': 'О приложении',
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
      'addGoal': 'Add goal',
      'addTask': 'Add task',
      'weeklyGoals': 'Weekly goals',
      'dayNotes': 'Day notes',
      'analytics': 'Analytics',
      'totalTasks': 'Total tasks',
      'productiveDay': 'Productive day',
      'about': 'About',
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
