import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        context.go(AppRouter.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>(
      (auth) => auth.isAuthenticated,
    );

    if (isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRouter.home);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primarySage.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 80,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.h3.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                  children: const [
                    TextSpan(text: 'UB'),
                    TextSpan(
                      text: 'antu',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.h4.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                  children: const [
                    TextSpan(text: 'Bantu sesama, '),
                    TextSpan(
                      text: 'ringankan',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                    TextSpan(text: ' bersama'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Platform bantuan antar mahasiswa\nUniversitas Brawijaya',
                textAlign: TextAlign.center,
                style: AppTypography.body1.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Masuk',
                type: CustomButtonType.primary,
                onPressed: () => context.push(AppRouter.login),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Daftar',
                type: CustomButtonType.outline,
                onPressed: () => context.push(AppRouter.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
