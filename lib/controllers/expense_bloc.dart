import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:pem/controllers/expense_event.dart';
import 'package:pem/controllers/expense_state.dart';
import 'package:pem/controllers/api_service.dart';
import 'package:pem/controllers/database_helper.dart';
import 'package:pem/controllers/storage_service.dart';
import 'package:pem/controllers/notification_service.dart';
import 'package:pem/model/category_model.dart';
import 'package:pem/model/expense_transaction.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final DatabaseHelper databaseHelper;
  final ApiService apiService;
  final StorageService storageService;
  final NotificationService notificationService;

  ExpenseBloc({
    required this.databaseHelper,
    required this.apiService,
    required this.storageService,
    required this.notificationService,
  }) : super(const ExpenseState(isLoading: true)) {
    on<LoadExpenseData>(_onLoadExpenseData);
    on<AddCategoryRequested>(_onAddCategoryRequested);
    on<DeleteCategoryRequested>(_onDeleteCategoryRequested);
    on<AddTransactionRequested>(_onAddTransactionRequested);
    on<DeleteTransactionRequested>(_onDeleteTransactionRequested);
    on<SyncRequested>(_onSyncRequested);
    on<UpdateBudgetLimitRequested>(_onUpdateBudgetLimitRequested);
  }

  Future<void> _onLoadExpenseData(LoadExpenseData event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      var categories = await databaseHelper.getCategories();
      final token = await storageService.getToken();
      if (token != null) {
        try {
          final serverCategories = await apiService.fetchCategories(token);
          for (final category in serverCategories) {
            await databaseHelper.insertCategory(category);
          }

          final serverTransactions = await apiService.fetchTransactions(token);
          for (final transaction in serverTransactions) {
            await databaseHelper.insertTransaction(transaction);
          }

          categories = await databaseHelper.getCategories();
        } catch (e) {
          // If remote load fails, still use local stored data.
        }
      }

      final transactions = await databaseHelper.getAllTransactions();
      final totalIncome = await databaseHelper.getTotalIncome();
      final totalExpense = await databaseHelper.getTotalExpense();
      final budgetLimit = await storageService.getBudgetLimit();
      final monthlyExpense = await databaseHelper.getMonthlyExpenseSum(DateTime.now().year, DateTime.now().month);
      final hasBudgetAlert = monthlyExpense > budgetLimit;

      emit(state.copyWith(
        categories: categories,
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        monthlyExpense: monthlyExpense,
        budgetLimit: budgetLimit,
        hasBudgetAlert: hasBudgetAlert,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCategoryRequested(AddCategoryRequested event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final id = const Uuid().v4();
      final category = CategoryModel(id: id, name: event.name);
      await databaseHelper.insertCategory(category);
      final categories = await databaseHelper.getCategories();
      emit(state.copyWith(categories: categories, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCategoryRequested(DeleteCategoryRequested event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await databaseHelper.softDeleteCategory(event.id);
      final categories = await databaseHelper.getCategories();
      final transactions = await databaseHelper.getRecentTransactions();
      final totalIncome = await databaseHelper.getTotalIncome();
      final totalExpense = await databaseHelper.getTotalExpense();
      emit(state.copyWith(
        categories: categories,
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddTransactionRequested(AddTransactionRequested event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final id = const Uuid().v4();
      final timestamp = DateTime.now().toIso8601String();
      final transaction = ExpenseTransaction(
        id: id,
        amount: event.amount,
        note: event.note,
        type: event.type,
        categoryId: event.categoryId,
        categoryName: event.categoryName,
        timestamp: timestamp,
      );

      await databaseHelper.insertTransaction(transaction);
      final transactions = await databaseHelper.getAllTransactions();
      final totalIncome = await databaseHelper.getTotalIncome();
      final totalExpense = await databaseHelper.getTotalExpense();
      final budgetLimit = await storageService.getBudgetLimit();
      final monthlyExpense = await databaseHelper.getMonthlyExpenseSum(DateTime.now().year, DateTime.now().month);
      final hasBudgetAlert = monthlyExpense > budgetLimit;

      if (transaction.isDebit && monthlyExpense > budgetLimit) {
        await notificationService.showBudgetAlert(
          'Budget Limit Exceeded',
          'Your monthly expenses have crossed ₹$budgetLimit.',
        );
      }

      emit(state.copyWith(
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        monthlyExpense: monthlyExpense,
        budgetLimit: budgetLimit,
        hasBudgetAlert: hasBudgetAlert,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteTransactionRequested(DeleteTransactionRequested event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await databaseHelper.softDeleteTransaction(event.id);
      final transactions = await databaseHelper.getAllTransactions();
      final totalIncome = await databaseHelper.getTotalIncome();
      final totalExpense = await databaseHelper.getTotalExpense();
      final monthlyExpense = await databaseHelper.getMonthlyExpenseSum(DateTime.now().year, DateTime.now().month);
      final hasBudgetAlert = monthlyExpense > state.budgetLimit;
      emit(state.copyWith(
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        monthlyExpense: monthlyExpense,
        hasBudgetAlert: hasBudgetAlert,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateBudgetLimitRequested(UpdateBudgetLimitRequested event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await storageService.saveBudgetLimit(event.budgetLimit);
      final totalExpense = await databaseHelper.getTotalExpense();
      final hasBudgetAlert = totalExpense > event.budgetLimit;
      emit(state.copyWith(budgetLimit: event.budgetLimit, hasBudgetAlert: hasBudgetAlert, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSyncRequested(SyncRequested event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(isSyncing: true, errorMessage: null));
    try {
      final deletedTransactions = await databaseHelper.getDeletedTransactions();
      final deleteTransactionIds = deletedTransactions.map((t) => t.id).toList();
      final deletedCategoryIds = (await databaseHelper.getDeletedCategories()).map((c) => c.id).toList();

      if (deleteTransactionIds.isNotEmpty) {
        await apiService.deleteTransactions(deleteTransactionIds, event.token);
        for (final id in deleteTransactionIds) {
          await databaseHelper.deleteTransactionPermanently(id);
        }
      }

      if (deletedCategoryIds.isNotEmpty) {
        await apiService.deleteCategories(deletedCategoryIds, event.token);
        for (final id in deletedCategoryIds) {
          await databaseHelper.deleteCategoryPermanently(id);
        }
      }

      final unsyncedCategories = await databaseHelper.getUnsyncedCategories();
      final syncedCategoryIds = await apiService.addCategories(unsyncedCategories, event.token);
      for (final id in syncedCategoryIds) {
        await databaseHelper.markCategorySynced(id);
      }

      final unsyncedTransactions = await databaseHelper.getUnsyncedTransactions();
      final syncedTransactionIds = await apiService.addTransactions(unsyncedTransactions, event.token);
      for (final id in syncedTransactionIds) {
        await databaseHelper.markTransactionSynced(id);
      }

      final categories = await databaseHelper.getCategories();
      final transactions = await databaseHelper.getAllTransactions();
      final totalIncome = await databaseHelper.getTotalIncome();
      final totalExpense = await databaseHelper.getTotalExpense();
      final monthlyExpense = await databaseHelper.getMonthlyExpenseSum(DateTime.now().year, DateTime.now().month);
      final hasBudgetAlert = monthlyExpense > state.budgetLimit;
      emit(state.copyWith(
        categories: categories,
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        monthlyExpense: monthlyExpense,
        hasBudgetAlert: hasBudgetAlert,
        isSyncing: false,
      ));
    } catch (e) {
      emit(state.copyWith(isSyncing: false, errorMessage: e.toString()));
    }
  }
}
