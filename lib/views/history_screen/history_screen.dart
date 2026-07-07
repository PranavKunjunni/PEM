import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pem/controllers/expense_bloc.dart';
import 'package:pem/controllers/expense_event.dart';
import 'package:pem/controllers/expense_state.dart';
import 'package:pem/widgets/transaction_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(18, 18, 18, 1),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final transactions = state.transactions;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 64, left: 16, right: 16,),
                  child: Text(
                    "Transactions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: transactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'No transaction history yet.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return TransactionCard(
                              title: transaction.note,
                              category: transaction.categoryName,
                              date: _formatDate(transaction.timestamp),
                              amount: '${transaction.isCredit ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(0)}',
                              isIncome: transaction.isCredit,
                              onDelete: () {
                                context.read<ExpenseBloc>().add(DeleteTransactionRequested(transaction.id));
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
