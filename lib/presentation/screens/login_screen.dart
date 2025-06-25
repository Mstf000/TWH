import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twh/presentation/screens/admin_home_screen.dart';
import 'package:twh/presentation/viewmodel/auth_viewmodel.dart';
import 'package:twh/presentation/widgets/connectivity_banner.dart';
import 'home_screen.dart';
import 'registeration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _handleLogin() async {
    final auth = context.read<AuthViewModel>();
    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (success) {
      final isAdmin = await auth.isAdmin(); // Call the isAdmin check

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              isAdmin ? const AdminHomeScreen() : const HomeScreen(),
        ),
      );
    } else {
      final error = auth.errorMessage ?? "Login failed";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF9F6FB), Color(0xFFE8DAEF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Hero(
                      tag: 'twh_logo',
                      child: Image.asset(
                        'assets/logo.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Welcome Back 👋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A2E76),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    //     );
                    //   },
                    //   child: const Text(
                    //     'Don’t have an account? Register',
                    //     style: TextStyle(fontWeight: FontWeight.w500),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          // const Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: ConnectivityBanner(),
          // ),
        ],
      ),
    );
  }
}
