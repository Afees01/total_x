import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:total_x/core/utils/app_colors.dart';
import 'package:total_x/core/utils/app_text_styles.dart';
import 'package:total_x/core/widgets/app_button.dart';
import 'package:total_x/core/widgets/app_text_field.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_bloc.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_event.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_state.dart';
import 'package:total_x/user/presentation/pages/otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  String phone = '';

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _sendOtp(BuildContext context) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty || trimmed.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number.')),
      );
      return;
    }
    context.read<OtpBloc>().add(SendOtpEvent(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpPage(phone: phone, reqId: state.reqId),
            ),
          );
        }
        if (state is OtpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<OtpBloc, OtpState>(
        builder: (context, state) {
          final isSending = state is OtpSending;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Illustration
                    Center(
                      child: Image.asset(
                        'assets/image/Login.png',
                        height: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          width: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F4FD),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.phone_android_rounded,
                            size: 72,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text('Enter Phone', style: AppTextStyles.heading),
                    const SizedBox(height: 8),
                    const Text(
                      'We will send you a verification code.',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 24),

                    // Phone field
                    AppTextField(
                      controller: phoneController,
                      hint: 'Enter Phone Number',
                      isPhone: true,
                      onChanged: (v) => phone = v,
                    ),

                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        style: AppTextStyles.caption,
                        children: [
                          TextSpan(text: "By Continuing, I agree to TotalX's "),
                          TextSpan(
                            text: 'Terms and condition',
                            style: TextStyle(
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' & '),
                          TextSpan(
                            text: 'privacy policy',
                            style: TextStyle(
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Get OTP',
                      isLoading: isSending,
                      onTap: () => _sendOtp(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
