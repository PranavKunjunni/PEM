import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pem/controllers/auth_bloc.dart';
import 'package:pem/controllers/auth_event.dart';
import 'package:pem/controllers/auth_state.dart';
import 'package:pem/views/walkthrough/walkthrough.dart';
import 'package:pem/widgets/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AuthBloc>().add(LoadAuthRequested());
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _goToNextScreen();
    });
  }

  void _goToNextScreen() {
    if (_didNavigate) return;
    _didNavigate = true;
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const Walkthrough(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToNextScreen,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(18, 18, 18, 1),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SvgPicture.asset(
                  "assets/images/logo.svg",
                  width: 133,
                  height: 104,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
