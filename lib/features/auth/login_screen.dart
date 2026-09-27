import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smyl_button.dart';
import '../../core/widgets/smyl_logo.dart';
import '../../core/widgets/smyl_text_field.dart';
import '../../shared/models/user_model.dart';
import '../../shared/services/app_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'lakshmi.n@smyl.global');
  final _passwordController = TextEditingController(text: '••••••••••••');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.push(
          AppRoutes.otpVerify,
          extra: {
            'phoneOrEmail': _emailController.text,
            'isLogin': true,
          },
        );
      }
    });
  }

  void _demoLoginAsAdmin() {
    ref.read(appRepositoryProvider).switchUserRole(UserRole.admin);
    context.go(AppRoutes.admin);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Brand Mark
              const Center(
                child: SmylLogo(size: 52, showText: true, showTagline: true),
              ),
              const SizedBox(height: 36),

              Text(
                'Welcome Back',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your credentials to access your global logistics dashboard.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 28),

              // Inputs
              SmylTextField(
                controller: _emailController,
                label: 'EMAIL OR MOBILE NUMBER',
                hintText: 'user@smyl.global or +91 98490...',
                prefixIcon: const Icon(
                  Icons.alternate_email_rounded,
                  color: AppColors.slate,
                  size: 20,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              SmylTextField(
                controller: _passwordController,
                label: 'PASSWORD',
                hintText: 'Enter your password',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.slate,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.slate,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                          activeColor: AppColors.electricCyan,
                          checkColor: AppColors.obsidian,
                          side: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember Me',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateLight,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset instructions sent to registered email.'),
                          backgroundColor: AppColors.deepSpace,
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.electricCyan,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SmylButton(
                text: 'Sign In via Secure OTP',
                onPressed: _handleLogin,
                isLoading: _isLoading,
                variant: SmylButtonVariant.primary,
              ),

              const SizedBox(height: 20),

              // Demo Shortcut Row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEVELOPER & DEMO FAST-SWITCH',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.champagneSand,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SmylButton(
                            text: 'Direct App Access',
                            height: 38,
                            variant: SmylButtonVariant.secondary,
                            onPressed: () => context.go(AppRoutes.mainShell),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SmylButton(
                            text: 'Admin Mobile Ops',
                            height: 38,
                            variant: SmylButtonVariant.outline,
                            onPressed: _demoLoginAsAdmin,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Sign Up Link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.slateLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: Text(
                        'Create Account',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.electricCyan,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
