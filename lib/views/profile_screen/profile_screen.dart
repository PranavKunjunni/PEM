import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pem/controllers/auth_bloc.dart';
import 'package:pem/controllers/auth_event.dart';
import 'package:pem/controllers/auth_state.dart';
import 'package:pem/controllers/expense_bloc.dart';
import 'package:pem/controllers/expense_event.dart';
import 'package:pem/controllers/expense_state.dart';
import 'package:pem/views/login_screen/login_screen.dart';
import 'package:pem/widgets/custom_text_field.dart';
import 'package:pem/widgets/editable_profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  String nickname = "User";

  late TextEditingController namecontroller;
  final TextEditingController numbercontroller = TextEditingController();
  final TextEditingController newCategory = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      nickname = authState.nickname;
    }
    namecontroller = TextEditingController(text: nickname);
  }

  @override
  void dispose() {
    namecontroller.dispose();
    numbercontroller.dispose();
    newCategory.dispose();
    super.dispose();
  }

  void saveNickname() {
    final newName = namecontroller.text.trim();
    if (newName.isEmpty) return;
    context.read<AuthBloc>().add(UpdateNicknameRequested(newName));
    setState(() {
      nickname = newName;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 64,
                left: 16,
                right: 16,
              ),
              child: Text(
                "Profile & Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "NICKNAME",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EditableProfileCard(
                isEditing: isEditing,
                nickname: nickname,
                controller: namecontroller,
                onEdit: () {
                  setState(() {
                    namecontroller.text = nickname;
                    isEditing = true;
                  });
                },
                onSave: saveNickname,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(
              color: Color(0xFF3A3A3A),
              thickness: 1,
              height: 24,
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 20,
                  right: 16,
                  bottom: 20,
                ),
                // height: 145,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ALERT LIMIT (₹)",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: numbercontroller,
                            hintText: "Amount ( ₹ )",
                            keyboardType: TextInputType.number,
                            onChanged: (_) {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 70,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              final value = int.tryParse(numbercontroller.text.trim());
                              if (value == null || value <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enter a valid budget amount.')),
                                );
                                return;
                              }
                              context.read<ExpenseBloc>().add(UpdateBudgetLimitRequested(value));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Budget limit updated.')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF312ECB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Set",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    BlocBuilder<ExpenseBloc, ExpenseState>(
                      builder: (context, expenseState) {
                        return Text(
                          "Current Limit: ₹${expenseState.budgetLimit}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(
              color: Color(0xFF3A3A3A),
              thickness: 1,
              height: 24,
            ),
            const SizedBox(
              height: 16,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "CATEGORIES",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(.15),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newCategory,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "New Category Name",
                              hintStyle: const TextStyle(
                                color: Colors.white54,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2A2A2A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 70,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              final newCategoryName = newCategory.text.trim();
                              if (newCategoryName.isEmpty) return;
                              context.read<ExpenseBloc>().add(AddCategoryRequested(newCategoryName));
                              newCategory.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Category added locally.')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF312ECB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                      color: Color(0xFF3A3A3A),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<ExpenseBloc, ExpenseState>(
                      builder: (context, expenseState) {
                        final categories = expenseState.categories;
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x26B50303),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      context.read<ExpenseBloc>().add(DeleteCategoryRequested(category.id));
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            const Divider(
              color: Color(0xFF3A3A3A),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "CLOUD SYNC",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final canSync = authState is AuthAuthenticated;
                  return InkWell(
                    onTap: canSync
                        ? () {
                            context.read<ExpenseBloc>().add(SyncRequested((authState as AuthAuthenticated).token));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sync requested.')),
                            );
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4340CA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sync To Cloud",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Sync and update data to the backend",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SvgPicture.asset(
                            "assets/images/cloud.svg",
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                width: 343,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(.15),
                  ),
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Log Out ",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        SvgPicture.asset(
                          "assets/images/logout.svg",
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 120,
            ),
          ],
        ),
      ),
    );
  }
}
