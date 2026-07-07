import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pem/model/category_model.dart';
import 'package:pem/model/expense_transaction.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'expense_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDatabase,
    );
  }

  Future<void> _onCreateDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_synced INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        note TEXT NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_synced INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await database;
    await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> softDeleteCategory(String id) async {
    final db = await database;
    await db.update('categories', {'is_deleted': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> softDeleteTransaction(String id) async {
    final db = await database;
    await db.update('transactions', {'is_deleted': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCategoryPermanently(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransactionPermanently(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markCategorySynced(String id) async {
    final db = await database;
    await db.update('categories', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markTransactionSynced(String id) async {
    final db = await database;
    await db.update('transactions', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CategoryModel>> getCategories({bool includeDeleted = false}) async {
    final db = await database;
    final where = includeDeleted ? null : 'is_deleted = 0';
    final rows = await db.query('categories', where: where, orderBy: 'name ASC');
    return rows.map((row) => CategoryModel.fromMap(row)).toList();
  }

  Future<List<CategoryModel>> getUnsyncedCategories() async {
    final db = await database;
    final rows = await db.query(
      'categories',
      where: 'is_synced = 0 AND is_deleted = 0',
      orderBy: 'name ASC',
    );
    return rows.map((row) => CategoryModel.fromMap(row)).toList();
  }

  Future<List<CategoryModel>> getDeletedCategories() async {
    final db = await database;
    final rows = await db.query(
      'categories',
      where: 'is_deleted = 1',
    );
    return rows.map((row) => CategoryModel.fromMap(row)).toList();
  }

  Future<List<ExpenseTransaction>> getRecentTransactions({int limit = 10}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
      LIMIT ?
    ''', [limit]);
    return rows.map((row) => ExpenseTransaction.fromMap(row)).toList();
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
    ''');
    return rows.map((row) => ExpenseTransaction.fromMap(row)).toList();
  }

  Future<List<ExpenseTransaction>> getUnsyncedTransactions() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      WHERE t.is_synced = 0 AND t.is_deleted = 0
      ORDER BY t.timestamp DESC
    ''');
    return rows.map((row) => ExpenseTransaction.fromMap(row)).toList();
  }

  Future<List<ExpenseTransaction>> getDeletedTransactions() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      WHERE t.is_deleted = 1
    ''');
    return rows.map((row) => ExpenseTransaction.fromMap(row)).toList();
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as value
      FROM transactions
      WHERE is_deleted = 0 AND LOWER(type) = 'credit'
    ''');
    return (result.first['value'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as value
      FROM transactions
      WHERE is_deleted = 0 AND LOWER(type) = 'debit'
    ''');
    return (result.first['value'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> clearAllLocalData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
  }

  Future<double> getMonthlyExpenseSum(int year, int month) async {
    final db = await database;
    final monthString = month.toString().padLeft(2, '0');
    final period = '$year-$monthString';
    final result = await db.rawQuery('''
      SELECT SUM(amount) as value
      FROM transactions
      WHERE is_deleted = 0 AND LOWER(type) = 'debit'
        AND SUBSTR(timestamp, 1, 7) = ?
    ''', [period]);
    return (result.first['value'] as num?)?.toDouble() ?? 0.0;
  }
}
