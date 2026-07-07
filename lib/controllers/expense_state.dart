import 'package:equatable/equatable.dart';
import 'package:pem/model/category_model.dart';
import 'package:pem/model/expense_transaction.dart';

class ExpenseState extends Equatable {
  final List<CategoryModel> categories;
  final List<ExpenseTransaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double monthlyExpense;
  final int budgetLimit;
  final bool isLoading;
  final bool isSyncing;
  final bool hasBudgetAlert;
  final String? errorMessage;

  const ExpenseState({
    this.categories = const [],
    this.transactions = const [],
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.monthlyExpense = 0.0,
    this.budgetLimit = 1000,
    this.isLoading = false,
    this.isSyncing = false,
    this.hasBudgetAlert = false,
    this.errorMessage,
  });

  ExpenseState copyWith({
    List<CategoryModel>? categories,
    List<ExpenseTransaction>? transactions,
    double? totalIncome,
    double? totalExpense,
    double? monthlyExpense,
    int? budgetLimit,
    bool? isLoading,
    bool? isSyncing,
    bool? hasBudgetAlert,
    String? errorMessage,
  }) {
    return ExpenseState(
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      hasBudgetAlert: hasBudgetAlert ?? this.hasBudgetAlert,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        transactions,
        totalIncome,
        totalExpense,
        monthlyExpense,
        budgetLimit,
        isLoading,
        isSyncing,
        hasBudgetAlert,
        errorMessage,
      ];
}
