import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smyl_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneOrEmail;
  final bool isLogin;

  const OtpVerificationScreen({
    super.key,
    required this.phoneOrEmail,
    this.isLogin = true,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  int _resendCountdown = 45;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _resendCountdown = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _autoFillDemoOtp() {
    const demo = '739104';
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = demo[i];
    }
    _verifyOtp();
  }

  void _verifyOtp() {
    if (_currentOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the verification code.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isVerifying = false);
        context.go(AppRoutes.mainShell);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'AUTHENTICATION PROTOCOL',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Phone\n& Identity',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.slateLight,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit secure handshake OTP to '),
                    TextSpan(
                      text: widget.phoneOrEmail,
                      style: const TextStyle(
                        color: AppColors.electricCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 6 PIN Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 22,
                        color: AppColors.electricCyan,
                      ),
                      cursorColor: AppColors.electricCyan,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: AppColors.deepSpace,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceBorder,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.electricCyan,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_currentOtp.length == 6) {
                          _verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Countdown / Resend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _resendCountdown > 0
                        ? 'Resend OTP in 0:${_resendCountdown.toString().padLeft(2, '0')}s'
                        : 'Code expired',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
                  TextButton(
                    onPressed: _resendCountdown == 0 ? _startTimer : null,
                    child: Text(
                      'Resend SMS Code',
                      style: AppTypography.labelUppercase.copyWith(
                        color: _resendCountdown == 0
                            ? AppColors.electricCyan
                            : AppColors.slateDark,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Auto-fill Test Code Shortcut
              Center(
                child: TextButton.icon(
                  onPressed: _autoFillDemoOtp,
                  icon: const Icon(
                    Icons.flash_on_rounded,
                    size: 16,
                    color: AppColors.champagneSand,
                  ),
                  label: Text(
                    'Auto-fill Secure Demo OTP',
                    style: AppTypography.labelAccent.copyWith(
                      color: AppColors.champagneSand,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              SmylButton(
                text: 'Verify & Enter App',
                onPressed: _verifyOtp,
                isLoading: _isVerifying,
                variant: SmylButtonVariant.primary,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
