import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pem/controllers/auth_bloc.dart';
import 'package:pem/controllers/auth_event.dart';
import 'package:pem/controllers/auth_state.dart';
import 'package:pem/widgets/buttons.dart';
import 'package:pem/widgets/custom_text_field.dart';
import 'package:pem/widgets/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController nameController = TextEditingController();

  bool isValid = false;

  @override
  void initState() {
    super.initState();

    nameController.addListener(() {
      setState(() {
        isValid = nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (_) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(18, 18, 18, 1),
        body: SafeArea(
          child: Padding(
          padding: const EdgeInsets.only(
            top: 64,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "👋 What should we call you?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "This name stays only on your device.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: nameController,
                hintText: "Enter Name",
                prefixText: "Eg: ",
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[a-zA-Z ]"),
                  ),
                ],
                suffixIcon: isValid
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : null, onChanged: (_) {  },
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  return Button(
                    text: loading ? 'Creating account...' : 'Continue',
                    onPressed: !isValid || loading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                                  CreateAccountRequested(
                                    nickname: nameController.text.trim(),
                                  ),
                                );
                          },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}