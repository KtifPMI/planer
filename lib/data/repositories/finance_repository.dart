import 'package:uuid/uuid.dart';
import '../models/finance.dart';
import '../services/storage_service.dart';

class FinanceRepository {
  final _transactions = StorageService.transactionsBox;
  final _categories = StorageService.categoriesBox;
  final _savings = StorageService.savingsBox;
  final _debts = StorageService.debtsBox;
  static const _uuid = Uuid();

  // Transactions
  List<Transaction> getAllTransactions() => _transactions.values.toList();

  List<Transaction> getTransactionsForMonth(int year, int month) {
    return _transactions.values
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  List<Transaction> getTransactionsForDay(DateTime day) {
    return _transactions.values
        .where((t) =>
            t.date.year == day.year &&
            t.date.month == day.month &&
            t.date.day == day.day)
        .toList();
  }

  List<Transaction> getTransactionsByType(TransactionType type, int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => t.type == type)
        .toList();
  }

  double getTotalByType(TransactionType type, int year, int month) {
    return getTransactionsByType(type, year, month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getBalance(int year, int month) {
    return getTotalByType(TransactionType.income, year, month) -
        getTotalByType(TransactionType.expense, year, month);
  }

  Map<String, double> getExpensesByCategory(int year, int month) {
    final expenses = getTransactionsByType(TransactionType.expense, year, month);
    final map = <String, double>{};
    for (final t in expenses) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, double> getIncomeByCategory(int year, int month) {
    final income = getTransactionsByType(TransactionType.income, year, month);
    final map = <String, double>{};
    for (final t in income) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  double getTotalPlanAmount(TransactionType type, int year, int month) {
    return _categories.values
        .where((c) => c.type == type && c.planAmount != null)
        .fold(0, (sum, c) => sum + c.planAmount!);
  }

  double getPlanProgress(TransactionType type, int year, int month) {
    final plan = getTotalPlanAmount(type, year, month);
    if (plan <= 0) return 0;
    final fact = getTotalByType(type, year, month);
    return (fact / plan).clamp(0.0, double.infinity);
  }

  Future<void> addTransaction(Transaction t) =>
      _transactions.put(t.id, t);

  Future<void> updateTransaction(Transaction t) =>
      _transactions.put(t.id, t);

  Future<void> deleteTransaction(String id) =>
      _transactions.delete(id);

  static String generateId() => _uuid.v4();

  // Categories
  List<Category> getAllCategories() => _categories.values.toList();

  List<Category> getCategoriesByType(TransactionType type) {
    return _categories.values.where((c) => c.type == type).toList();
  }

  Category? getCategoryById(String id) => _categories.get(id);

  Future<void> addCategory(Category c) => _categories.put(c.id, c);

  Future<void> updateCategory(Category c) => _categories.put(c.id, c);

  Future<void> deleteCategory(String id) => _categories.delete(id);

  // Savings
  List<SavingsGoal> getAllSavings() => _savings.values.toList();

  Future<void> addSavingsGoal(SavingsGoal g) => _savings.put(g.id, g);

  Future<void> updateSavingsGoal(SavingsGoal g) => _savings.put(g.id, g);

  Future<void> deleteSavingsGoal(String id) => _savings.delete(id);

  double get totalSaved => _savings.values.fold(0, (s, g) => s + g.currentAmount);
  double get totalTarget => _savings.values.fold(0, (s, g) => s + g.targetAmount);

  // Debts
  List<Debt> getAllDebts() => _debts.values.toList();

  List<Debt> getActiveDebts() =>
      _debts.values.where((d) => !d.isPaidOff).toList();

  Future<void> addDebt(Debt d) => _debts.put(d.id, d);

  Future<void> updateDebt(Debt d) => _debts.put(d.id, d);

  Future<void> deleteDebt(String id) => _debts.delete(id);

  double get totalDebt =>
      _debts.values.fold(0, (s, d) => s + d.remaining);

  double get totalPaid =>
      _debts.values.fold(0, (s, d) => s + d.paidAmount);
}
