import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smyl_button.dart';
import '../../core/widgets/smyl_text_field.dart';
import '../../shared/models/user_model.dart';
import '../../shared/services/app_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _cityController = TextEditingController();

  UserRole _selectedRole = UserRole.both;
  bool _termsAccepted = false;
  bool _prohibitedItemsDeclarationAccepted = false;
  bool _isLoading = false;

  void _handleRegister() {
    if (!_termsAccepted || !_prohibitedItemsDeclarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions and Prohibited Item Declaration.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ref.read(appRepositoryProvider).switchUserRole(_selectedRole);
        context.push(
          AppRoutes.otpVerify,
          extra: {
            'phoneOrEmail': _mobileController.text.isNotEmpty
                ? _mobileController.text
                : '+91 98490 12345',
            'isLogin': false,
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'CREATE SMYL ACCOUNT',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join the Global\nCarrying Protocol',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verified travellers and senders collaborate with complete compliance and escrow security.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 24),

              // First and Last Name
              Row(
                children: [
                  Expanded(
                    child: SmylTextField(
                      controller: _firstNameController,
                      label: 'FIRST NAME',
                      hintText: 'e.g. Rahul',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SmylTextField(
                      controller: _lastNameController,
                      label: 'LAST NAME',
                      hintText: 'e.g. Sharma',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SmylTextField(
                controller: _mobileController,
                label: 'MOBILE NUMBER (WITH COUNTRY CODE)',
                hintText: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.slate,
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),

              SmylTextField(
                controller: _emailController,
                label: 'PRIMARY EMAIL',
                hintText: 'name@domain.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  color: AppColors.slate,
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),

              SmylTextField(
                controller: _passwordController,
                label: 'CREATE PASSWORD',
                hintText: 'At least 8 characters with numbers',
                obscureText: true,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.slate,
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SmylTextField(
                      controller: _countryController,
                      label: 'COUNTRY OF RESIDENCE',
                      hintText: 'India',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SmylTextField(
                      controller: _cityController,
                      label: 'HOME CITY',
                      hintText: 'Hyderabad',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Role selection chips
              Text(
                'PRIMARY OPERATING INTENT',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRoleChip('Sender', UserRole.sender),
                  const SizedBox(width: 8),
                  _buildRoleChip('Traveller', UserRole.traveller),
                  const SizedBox(width: 8),
                  _buildRoleChip('Both', UserRole.both),
                ],
              ),

              const SizedBox(height: 24),

              // Compliance & Terms Checkboxes
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _termsAccepted,
                            onChanged: (val) =>
                                setState(() => _termsAccepted = val ?? false),
                            activeColor: AppColors.electricCyan,
                            checkColor: AppColors.obsidian,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I agree to the SMYL Global Terms of Service, Escrow Settlement Rules, and International Carriage Governance.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.warmIvory,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _prohibitedItemsDeclarationAccepted,
                            onChanged: (val) => setState(() =>
                                _prohibitedItemsDeclarationAccepted =
                                    val ?? false),
                            activeColor: AppColors.warning,
                            checkColor: AppColors.obsidian,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Prohibited Item Declaration: I solemnly declare I will never request or carry narcotics, flammable items, lithium batteries, uncertified seeds, or regulated goods.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.champagneSand,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SmylButton(
                text: 'Verify Mobile via OTP',
                onPressed: _handleRegister,
                isLoading: _isLoading,
                variant: SmylButtonVariant.primary,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, UserRole role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.electricCyan.withOpacity(0.15)
                : AppColors.deepSpace,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.electricCyan : AppColors.surfaceBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 13,
                color: isSelected ? AppColors.electricCyan : AppColors.slateLight,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
