import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill demo credentials only when Firebase is not configured.
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.firebaseEnabled) {
      _emailPhoneController.text = 'mandar.salunkhe@itm.edu';
      _passwordController.text = 'Portea@123';
    }
  }

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProv.login(
      emailOrPhone: _emailPhoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      AppUtils.showToast(context, 'Welcome back to Portea Medical!',
          isSuccess: true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScaffold()),
      );
    } else {
      AppUtils.showToast(
        context,
        authProv.lastError ?? 'Login failed. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailPhoneController.text.trim();
    if (!email.contains('@')) {
      AppUtils.showToast(
        context,
        'Enter your email above first, then tap Forgot password.',
        isError: true,
      );
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.sendPasswordReset(email);
    if (!mounted) return;
    AppUtils.showToast(
      context,
      ok
          ? 'Password reset link sent to $email'
          : (auth.lastError ?? 'Could not send reset email.'),
      isSuccess: ok,
      isError: !ok,
    );
  }

  void _quickFillDemo() {
    setState(() {
      _emailPhoneController.text = 'mandar.salunkhe@itm.edu';
      _passwordController.text = 'Portea@123';
    });
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final fbOn = Provider.of<AuthProvider>(context, listen: false).firebaseEnabled;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppTheme.primaryTeal,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Welcome to Portea',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to book doctor-prescribed home medical care.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email / Phone field
                    Text(
                      fbOn ? 'Email Address' : 'Email or Mobile Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailPhoneController,
                      decoration: InputDecoration(
                        hintText: fbOn ? 'e.g. name@itm.edu' : 'e.g. name@itm.edu or 9876543210',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return fbOn
                              ? 'Please enter your email address'
                              : 'Please enter email or phone number';
                        }
                        if (fbOn && !val.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password field
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    if (fbOn)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Demo Login Button (hidden when real Firebase auth is on)
                    if (!fbOn)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _quickFillDemo,
                        icon: const Icon(Icons.flash_on, size: 18),
                        label: const Text('One-Tap Demo Login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          side: const BorderSide(
                              color: AppTheme.primaryTeal, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // University Project Footer Note
                    Center(
                      child: Text(
                        '${AppConstants.projectTitle}\n${AppConstants.university}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
