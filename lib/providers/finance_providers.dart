import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/finance.dart';
import '../data/repositories/finance_repository.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository();
});

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

final dayTransactionsProvider = Provider<List<Transaction>>((ref) {
  final day = ref.watch(selectedDayProvider);
  if (day == null) return [];
  return ref.watch(financeRepositoryProvider)
      .getTransactionsForDay(day);
});

final allTransactionsProvider = Provider<List<Transaction>>((ref) {
  return ref.watch(financeRepositoryProvider).getAllTransactions();
});

final monthTransactionsProvider = Provider<List<Transaction>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider)
      .getTransactionsForMonth(month.year, month.month);
});

final monthIncomeProvider = Provider<double>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider)
      .getTotalByType(TransactionType.income, month.year, month.month);
});

final monthExpenseProvider = Provider<double>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider)
      .getTotalByType(TransactionType.expense, month.year, month.month);
});

final monthBalanceProvider = Provider<double>((ref) {
  final income = ref.watch(monthIncomeProvider);
  final expense = ref.watch(monthExpenseProvider);
  return income - expense;
});

final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(financeRepositoryProvider)
      .getCategoriesByType(TransactionType.income);
});

final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(financeRepositoryProvider)
      .getCategoriesByType(TransactionType.expense);
});

final allCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(financeRepositoryProvider).getAllCategories();
});

final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider)
      .getExpensesByCategory(month.year, month.month);
});

final incomeByCategoryProvider = Provider<Map<String, double>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider)
      .getIncomeByCategory(month.year, month.month);
});

// Savings
final allSavingsProvider = Provider<List<SavingsGoal>>((ref) {
  return ref.watch(financeRepositoryProvider).getAllSavings();
});

final totalSavedProvider = Provider<double>((ref) {
  final savings = ref.watch(allSavingsProvider);
  return savings.fold(0, (s, g) => s + g.currentAmount);
});

final totalTargetProvider = Provider<double>((ref) {
  final savings = ref.watch(allSavingsProvider);
  return savings.fold(0, (s, g) => s + g.targetAmount);
});

// Debts
final allDebtsProvider = Provider<List<Debt>>((ref) {
  return ref.watch(financeRepositoryProvider).getAllDebts();
});

final activeDebtsProvider = Provider<List<Debt>>((ref) {
  return ref.watch(financeRepositoryProvider).getActiveDebts();
});

final totalDebtProvider = Provider<double>((ref) {
  final debts = ref.watch(allDebtsProvider);
  return debts.fold(0, (s, d) => s + d.remaining);
});

final totalPaidProvider = Provider<double>((ref) {
  final debts = ref.watch(allDebtsProvider);
  return debts.fold(0, (s, d) => s + d.paidAmount);
});

// Plan/Fact
final incomePlanProgressProvider = Provider<double>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider)
      .getPlanProgress(TransactionType.income, month.year, month.month);
});

final expensePlanProgressProvider = Provider<double>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepositoryProvider)
      .getPlanProgress(TransactionType.expense, month.year, month.month);
});

void invalidateAllFinance(WidgetRef ref) {
  ref.invalidate(monthIncomeProvider);
  ref.invalidate(monthExpenseProvider);
  ref.invalidate(monthBalanceProvider);
  ref.invalidate(monthTransactionsProvider);
  ref.invalidate(expensesByCategoryProvider);
  ref.invalidate(incomeByCategoryProvider);
  ref.invalidate(allSavingsProvider);
  ref.invalidate(totalSavedProvider);
  ref.invalidate(totalTargetProvider);
  ref.invalidate(allDebtsProvider);
  ref.invalidate(totalDebtProvider);
  ref.invalidate(totalPaidProvider);
}
