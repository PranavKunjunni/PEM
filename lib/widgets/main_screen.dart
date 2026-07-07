import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pem/controllers/expense_bloc.dart';
import 'package:pem/controllers/expense_event.dart';
import 'package:pem/controllers/expense_state.dart';
import 'package:pem/views/history_screen/history_screen.dart';
import 'package:pem/views/home_screen/home_screen.dart';
import 'package:pem/views/profile_screen/profile_screen.dart';
import 'package:pem/widgets/buttons.dart';

import 'package:pem/widgets/custom_bottom_navbar.dart';
import 'package:pem/widgets/custom_text_field.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late TabController _tabController;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    amountController.dispose();

    super.dispose();
  }

  final List<Widget> pages = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBody: true,
      body: pages[currentIndex],
      floatingActionButton: currentIndex == 0
          ? GestureDetector(
              onTap: () {
                _showAddTransactionBottomSheet();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF20DE39),
                      Color(0xFF147721),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  void _showAddTransactionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: 578,
          padding: const EdgeInsets.only(
            top: 32,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1F1F1F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Add Transaction",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                height: 52,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFF20DE39),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: "Expense"),
                    Tab(text: "Income"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _transactionForm("CATEGORY"),
                    _transactionForm("SOURCE"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _transactionForm(String heading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: titleController,
          hintText: "Title",
          keyboardType: TextInputType.text, onChanged: (_) {  },
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: amountController,
          hintText: "Amount (₹)",
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ], onChanged: (_) {  },
        ),
        const SizedBox(height: 20),
        Text(
          heading,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, expenseState) {
              final categories = expenseState.categories;
              final count = categories.isNotEmpty ? categories.length : 10;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: count,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final bool isSelected = selectedCategory == index;
                  final label = categories.isNotEmpty
                      ? categories[index].name
                      : 'Category $index';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0x80312ECB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF007AFF) : Colors.white38,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Container(
          // width: 343,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0x1A008500), // #008500 at 10% opacity
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0x1A008500),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 2), // move icon slightly down/up
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Expanded(
                child: Text(
                  "Everything you add here is saved only on your device.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Button(
            height: 48,
            width: 343,
            text: 'Save',
            onPressed: () => _saveTransaction(context),
          ),
        ),
        // const SizedBox(
        //   height: 16,
        // ),
      ],
    );
  }

  void _saveTransaction(BuildContext context) {
    final title = titleController.text.trim();
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid title and amount.')),
      );
      return;
    }

    final expenseBloc = context.read<ExpenseBloc>();
    final categoryList = expenseBloc.state.categories;
    final category = categoryList.isNotEmpty
        ? categoryList[selectedCategory % categoryList.length]
        : null;
    final categoryId = category?.id ?? 'uncategorized';
    final categoryName = category?.name ?? 'Uncategorized';
    final type = _tabController.index == 0 ? 'debit' : 'credit';

    expenseBloc.add(AddTransactionRequested(
      note: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
    ));

    Navigator.pop(context);
    titleController.clear();
    amountController.clear();
    setState(() {
      selectedCategory = 0;
    });
  }
}
