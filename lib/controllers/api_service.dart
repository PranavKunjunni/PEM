import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pem/controllers/network_service.dart';
import 'package:pem/model/category_model.dart';
import 'package:pem/model/expense_transaction.dart';

class ApiService {
  ApiService({this.useMock = false, NetworkService? networkService})
      : networkService = networkService ?? NetworkService();

  /// Set to true to bypass the real network calls and get back
  /// hardcoded "success" responses. Useful while the test server
  /// (appskilltest.zybotech.in) is returning 502s.
  final bool useMock;
  final NetworkService networkService;

  final String _baseUrl = 'https://appskilltest.zybotech.in';

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    if (useMock) {
      // Hardcoded OTP for local testing: 123456
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'status': 'success',
        'otp': '123456',
        'user_exists': false,
        'nickname': null,
        'token': 'mock-token-123',
      };
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/auth/send-otp/');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status']?.toString().toLowerCase();
      if (status != 'success') {
        throw Exception(json['message']?.toString() ?? 'Failed to send OTP');
      }
      return json;
    }

    throw Exception('Failed to send OTP: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createAccount(String phone, String nickname) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'status': 'success',
        'token': 'mock-token-123',
      };
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/auth/create-account/');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status']?.toString().toLowerCase();
      if (status != 'success') {
        throw Exception(json['message']?.toString() ?? 'Failed to create account');
      }
      return json;
    }

    throw Exception('Failed to create account: ${response.statusCode}');
  }

  Future<List<CategoryModel>> fetchCategories(String token) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return const [
        CategoryModel(
          id: '550e8400-e29b-41d4-a716-446655440000',
          name: 'Food',
          isSynced: true,
        ),
      ];
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/categories/');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status']?.toString().toLowerCase();
      if (status != 'success') {
        throw Exception(data['message']?.toString() ?? 'Failed to fetch categories');
      }

      final categories = (data['categories'] as List<dynamic>)
          .map((item) {
            final map = item as Map<String, dynamic>;
            return CategoryModel(
              id: map['id'] as String,
              name: map['name'] as String,
              isSynced: true,
              isDeleted: false,
            );
          })
          .toList();
      return categories;
    }

    throw Exception('Failed to fetch categories: ${response.statusCode}');
  }

  Future<List<ExpenseTransaction>> fetchTransactions(String token) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return const [
        ExpenseTransaction(
          id: 'f7d50524-660f-4a6a-a232-63f106e9f01c',
          amount: 50.0,
          note: 'travel',
          type: 'credit',
          categoryId: 'test2 category',
          categoryName: 'test2 category',
          timestamp: '2023-10-27T10:00:00Z',
          isSynced: true,
        ),
      ];
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/transactions/');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status']?.toString().toLowerCase();
      if (status != 'success') {
        throw Exception(data['message']?.toString() ?? 'Failed to fetch transactions');
      }

      final transactions = (data['transactions'] as List<dynamic>)
          .map((item) {
            final map = item as Map<String, dynamic>;
            final categoryName = map['category']?.toString() ?? map['category_name']?.toString() ?? 'Uncategorized';
            final categoryId = map['category_id']?.toString() ?? categoryName;
            final amountValue = map['amount'];
            final amount = amountValue is int ? amountValue.toDouble() : amountValue as double;
            return ExpenseTransaction(
              id: map['id'] as String,
              amount: amount,
              note: map['note']?.toString() ?? '',
              type: map['type']?.toString() ?? 'debit',
              categoryId: categoryId,
              categoryName: categoryName,
              timestamp: map['timestamp']?.toString() ?? '',
              isSynced: true,
              isDeleted: false,
            );
          })
          .toList();
      return transactions;
    }

    throw Exception('Failed to fetch transactions: ${response.statusCode}');
  }

  Future<List<String>> addCategories(List<CategoryModel> categories, String token) async {
    if (categories.isEmpty) return <String>[];

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return categories.map((c) => c.id).toList();
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/categories/add/');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'categories': categories
            .map((category) => {
                  'category_id': category.id,
                  'name': category.name,
                })
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['synced_ids'] as List<dynamic>);
    }

    throw Exception('Failed to sync categories');
  }

  Future<List<String>> deleteCategories(List<String> ids, String token) async {
    if (ids.isEmpty) return <String>[];

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ids;
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/categories/delete/');
    final request = http.Request('DELETE', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'ids': ids});

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['deleted_ids'] as List<dynamic>);
    }

    throw Exception('Failed to delete categories');
  }

  Future<List<String>> addTransactions(List<ExpenseTransaction> transactions, String token) async {
    if (transactions.isEmpty) return <String>[];

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return transactions.map((t) => t.id).toList();
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/transactions/add/');
    final bodyTransactions = transactions.map((transaction) {
      return {
        'id': transaction.id,
        'amount': transaction.amount,
        'note': transaction.note,
        'type': transaction.type,
        'category_id': transaction.categoryId,
        'timestamp': _formatTimestamp(transaction.timestamp),
      };
    }).toList();

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'transactions': bodyTransactions}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['synced_ids'] as List<dynamic>);
    }

    throw Exception('Failed to sync transactions');
  }

  Future<List<String>> deleteTransactions(List<String> ids, String token) async {
    if (ids.isEmpty) return <String>[];

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ids;
    }

    await networkService.ensureConnected();

    final uri = Uri.parse('$_baseUrl/transactions/delete/');
    final request = http.Request('DELETE', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'ids': ids});

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['deleted_ids'] as List<dynamic>);
    }

    throw Exception('Failed to delete transactions');
  }

  String _formatTimestamp(String isoTimestamp) {
    try {
      final dateTime = DateTime.parse(isoTimestamp);
      return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoTimestamp.replaceFirst('T', ' ').split('.').first;
    }
  }
}