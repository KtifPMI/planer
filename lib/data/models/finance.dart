import 'package:hive/hive.dart';

part 'finance.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  TransactionType type;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? note;

  Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    this.note,
  });
}

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  TransactionType type;

  @HiveField(4)
  double? planAmount;

  Category({
    required this.id,
    required this.name,
    this.icon = '📁',
    required this.type,
    this.planAmount,
  });
}

@HiveType(typeId: 5)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  DateTime? deadline;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);
}

@HiveType(typeId: 6)
class Debt extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  double paidAmount;

  @HiveField(4)
  double interestRate;

  @HiveField(5)
  double minPayment;

  @HiveField(6)
  String status;

  @HiveField(7)
  DateTime? deadline;

  Debt({
    required this.id,
    required this.name,
    required this.totalAmount,
    this.paidAmount = 0,
    this.interestRate = 0,
    this.minPayment = 0,
    this.status = 'active',
    this.deadline,
  });

  double get remaining => (totalAmount - paidAmount).clamp(0, double.infinity);
  double get progress => totalAmount > 0 ? paidAmount / totalAmount : 0;
  bool get isPaidOff => remaining <= 0;
}
