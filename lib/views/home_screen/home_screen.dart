import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pem/controllers/auth_bloc.dart';
import 'package:pem/controllers/auth_state.dart';
import 'package:pem/controllers/expense_bloc.dart';
import 'package:pem/controllers/expense_event.dart';
import 'package:pem/controllers/expense_state.dart';
import 'package:pem/widgets/monthly_limint_card.dart';
import 'package:pem/widgets/summary_card.dart';
import 'package:pem/widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isRed = false;

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
    } catch (_) {
      return timestamp.split('T').first;
    }
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(18, 18, 18, 1),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final nickname = context.select<AuthBloc, String?>(
            (bloc) => bloc.state is AuthAuthenticated
                ? (bloc.state as AuthAuthenticated).nickname
                : null,
          );

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 64, left: 16, right: 16),
                  child: Text(
                    '👋 Welcome, ${nickname ?? 'User'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Income',
                          amount: '₹${state.totalIncome.toStringAsFixed(0)}',
                          icon: Icons.arrow_downward,
                          startColor: const Color(0xFF0F8300),
                          endColor: const Color(0xFF031C00),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Expenses',
                          amount: '₹${state.totalExpense.toStringAsFixed(0)}',
                          icon: Icons.arrow_upward,
                          startColor: const Color(0xFFB50303),
                          endColor: const Color(0xFF250000),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MonthlyLimitCard(
                    spentAmount: state.monthlyExpense,
                    totalLimit: state.budgetLimit.toDouble(),

                    // Toggle Green <-> Red
                    isLimitExceeded: isRed,

                    onTap: () {
                      setState(() {
                        isRed = !isRed;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(
                  color: Color(0xFF3A3A3A),
                  thickness: 1,
                  height: 24,
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: state.transactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'No transactions yet.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.transactions.length > 10
                              ? 10
                              : state.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = state.transactions[index];

                            return TransactionCard(
                              title: transaction.note,
                              category: transaction.categoryName,
                              date: _formatDate(transaction.timestamp),
                              amount:
                                  '${transaction.isCredit ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(0)}',
                              isIncome: transaction.isCredit,
                              onDelete: () {
                                context.read<ExpenseBloc>().add(
                                      DeleteTransactionRequested(
                                        transaction.id,
                                      ),
                                    );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
