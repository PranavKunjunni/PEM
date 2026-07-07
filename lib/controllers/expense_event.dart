import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenseData extends ExpenseEvent {}

class AddCategoryRequested extends ExpenseEvent {
  final String name;

  const AddCategoryRequested(this.name);

  @override
  List<Object?> get props => [name];
}

class DeleteCategoryRequested extends ExpenseEvent {
  final String id;

  const DeleteCategoryRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class AddTransactionRequested extends ExpenseEvent {
  final String note;
  final double amount;
  final String type;
  final String categoryId;
  final String categoryName;

  const AddTransactionRequested({
    required this.note,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  List<Object?> get props => [note, amount, type, categoryId, categoryName];
}

class DeleteTransactionRequested extends ExpenseEvent {
  final String id;

  const DeleteTransactionRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class SyncRequested extends ExpenseEvent {
  final String token;

  const SyncRequested(this.token);

  @override
  List<Object?> get props => [token];
}

class UpdateBudgetLimitRequested extends ExpenseEvent {
  final int budgetLimit;

  const UpdateBudgetLimitRequested(this.budgetLimit);

  @override
  List<Object?> get props => [budgetLimit];
}
