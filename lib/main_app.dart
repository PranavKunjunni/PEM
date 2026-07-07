import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pem/controllers/api_service.dart';
import 'package:pem/controllers/auth_bloc.dart';
import 'package:pem/controllers/expense_bloc.dart';
import 'package:pem/controllers/expense_event.dart';
import 'package:pem/controllers/storage_service.dart';
import 'package:pem/controllers/database_helper.dart';
import 'package:pem/controllers/notification_service.dart';
import 'package:pem/views/splash_screen/splash_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final storageService = StorageService();
    final databaseHelper = DatabaseHelper.instance;
    final notificationService = NotificationService.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            apiService: apiService,
            storageService: storageService,
            databaseHelper: databaseHelper,
          ),
        ),
        BlocProvider<ExpenseBloc>(
          create: (_) => ExpenseBloc(
            databaseHelper: databaseHelper,
            apiService: apiService,
            storageService: storageService,
            notificationService: notificationService,
          )..add(LoadExpenseData()),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Manager',
        home: SplashScreen(),
      ),
    );
  }
}
