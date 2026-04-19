import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:total_x/core/utils/app_colors.dart';
import 'package:total_x/core/utils/app_text_styles.dart';
import 'package:total_x/core/widgets/app_button.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_bloc.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_event.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_state.dart';
import 'package:total_x/user/presentation/pages/home_page.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String reqId;

  const OtpPage({super.key, required this.phone, required this.reqId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  late String currentReqId;
  int secondsRemaining = 59;
  Timer? _countdownTimer;

  String get otp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    currentReqId = widget.reqId;
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => secondsRemaining = 59);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => secondsRemaining -= 1);
      }
    });
  }

  void _verifyOtp() {
    final trimmedOtp = otp.trim();
    if (trimmedOtp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit OTP.')),
      );
      return;
    }
    context.read<OtpBloc>().add(
          VerifyOtpEvent(reqId: currentReqId, otp: trimmedOtp),
        );
  }

  void _resendOtp() {
    if (secondsRemaining > 0) return;
    context.read<OtpBloc>().add(ResendOtpEvent(currentReqId));
  }

  String _maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    final last2 = phone.substring(phone.length - 2);
    final masked = '*' * (phone.length - 4);
    return '+91 $masked$last2';
  }

  Widget _buildOtpBox(int index, bool isVerifying) {
    return SizedBox(
      width: 56,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: !isVerifying,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.background,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        }
        if (state is OtpResent) {
          if (state.reqId.isNotEmpty) currentReqId = state.reqId;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully.')),
          );
          _startCountdown();
        }
        if (state is OtpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<OtpBloc, OtpState>(builder: (context, state) {
        final isVerifying = state is OtpVerifyLoading;
        final isResending = state is OtpResending;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: const BackButton(color: AppColors.textPrimary),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Illustration
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Image.asset(
                        'assets/image/OTP.png',
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
                  ),

                  const Text('OTP Verification', style: AppTextStyles.heading),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the verification code we just sent to your\nnumber ${_maskPhone(widget.phone)}',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 28),

                  // 4 OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      4,
                      (i) => Padding(
                        padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                        child: _buildOtpBox(i, isVerifying),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Timer
                  Text(
                    '${secondsRemaining.toString().padLeft(2, '0')} Sec',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Resend row
                  Row(
                    children: [
                      Text("Don't Get OTP? ", style: AppTextStyles.body),
                      GestureDetector(
                        onTap: (secondsRemaining == 0 && !isResending)
                            ? _resendOtp
                            : null,
                        child: isResending
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.accent),
                              )
                            : Text(
                                'Resend',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: secondsRemaining == 0
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  AppButton(
                    text: 'Verify',
                    isLoading: isVerifying,
                    onTap: _verifyOtp,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
