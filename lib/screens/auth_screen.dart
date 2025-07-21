import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_gradient_background.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;
  final void Function(String email)? onLogin;
  final void Function(String email)? onSignup;
  final VoidCallback? goToSignup;
  final VoidCallback? goToLogin;
  const AuthScreen({
    super.key,
    required this.isLogin,
    this.onLogin,
    this.onSignup,
    this.goToSignup,
    this.goToLogin,
  });
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!widget.isLogin && _passwordController.text != _confirmController.text) {
        setState(() => _error = 'Passwords do not match');
        return;
      }
      
      setState(() {
        _error = null;
        _isLoading = true;
      });

      try {
        if (widget.isLogin) {
          // Login
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          widget.onLogin?.call(_emailController.text.trim());
        } else {
          // Sign up
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          widget.onSignup?.call(_emailController.text.trim());
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _error = _getErrorMessage(e.code);
        });
      } catch (e) {
        setState(() {
          _error = 'An unexpected error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedGradientBackground(child: const SizedBox.expand()),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassCard(
                  borderRadius: 28,
                  blur: 24,
                  opacity: 0.22,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.spa, color: AppColors.primary, size: 48),
                          const SizedBox(height: 12),
                          Text(widget.isLogin ? 'Login' : 'Sign Up', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            obscureText: _obscure,
                            validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                          ),
                          if (!widget.isLogin) ...[
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _confirmController,
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Text(widget.isLogin ? 'Login' : 'Sign Up'),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: widget.isLogin ? widget.goToSignup : widget.goToLogin,
                            child: Text(widget.isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}