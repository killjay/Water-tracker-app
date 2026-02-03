import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../main.dart'; // For AuthWrapper
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to AuthWrapper which will route to onboarding or home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 34),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo - Droplet icon
                  const Icon(
                    Icons.water_drop,
                    size: 64,
                    color: Color(0xFFE2F163), // lime green accent
                  ),
                  const SizedBox(height: 16),
                  // App Title
                  const Text(
                    'Water Tracker',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF), // white
                      letterSpacing: 0.37,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                          fontFamily: 'Inter',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: const TextStyle(
                            color: Color(0x99EBEBF5), // tertiary label
                            fontSize: 17,
                            fontFamily: 'Inter',
                          ),
                          prefixIcon: const Icon(
                            Icons.mail,
                            size: 16,
                            color: Color(0xFF896CFE), // purple accent
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C1C1E), // secondary background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF38383A), // separator
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF38383A),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF896CFE), // purple accent
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                          fontFamily: 'Inter',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(
                            color: Color(0x99EBEBF5),
                            fontSize: 17,
                            fontFamily: 'Inter',
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            size: 16,
                            color: Color(0xFF896CFE),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 16,
                              color: const Color(0xFF896CFE),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C1C1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF38383A),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF38383A),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF896CFE),
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2F163), // lime green
                            foregroundColor: const Color(0xFF000000), // black text
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF000000),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xFF38383A), // separator
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Color(0xFF38383A),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google sign-in button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  print('[LoginScreen] Google Sign-In button pressed');
                                  final success =
                                      await authProvider.signInWithGoogle();
                                  print('[LoginScreen] Google Sign-In result: $success');
                                  if (context.mounted) {
                                    if (success) {
                                      print('[LoginScreen] Navigating to AuthWrapper');
                                      // Navigate to AuthWrapper which will route to onboarding or home
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
                                        (route) => false,
                                      );
                                    } else {
                                      print('[LoginScreen] Google Sign-In failed or cancelled');
                                      final msg = authProvider.errorMessage ??
                                          'Google sign-in cancelled or failed';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(msg),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C1C1E),
                            side: const BorderSide(
                              color: Color(0xFF38383A),
                              width: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.language,
                                size: 20,
                                color: Color(0xFF896CFE),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFFFFFFFF),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sign up link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFE2F163), // lime green
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
