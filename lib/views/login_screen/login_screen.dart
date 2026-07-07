import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pem/controllers/auth_bloc.dart';
import 'package:pem/controllers/auth_event.dart';
import 'package:pem/controllers/auth_state.dart';
import 'package:pem/views/otp_screen/otp_screen.dart';
import 'package:pem/widgets/buttons.dart';
import 'package:pem/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  bool get _isPhoneValid => phoneController.text.trim().length == 10;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(phone: state.phone),
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(18, 18, 18, 1),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 64, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Get Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Log In Using Phone & OTP",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: phoneController,
                  hintText: "Phone",
                  prefixText: "+91 | ",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return Button(
                      text: loading ? 'Requesting OTP...' : 'Continue',
                      onPressed: !_isPhoneValid || loading
                          ? null
                          : () {
                              final phone = '+91${phoneController.text.trim()}';
                              context.read<AuthBloc>().add(SendOtpRequested(phone));
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
