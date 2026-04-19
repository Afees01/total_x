import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String otp = '';
  late String currentReqId;
  int secondsRemaining = 10;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    currentReqId = widget.reqId;
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      secondsRemaining = 10;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining -= 1;
        });
      }
    });
  }

  void _verifyOtp() {
    final trimmedOtp = otp.trim();

    if (trimmedOtp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP.')),
      );
      return;
    }

    // Check if OTP contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmedOtp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP should contain only digits.')),
      );
      return;
    }

    // Check if OTP is between 4-6 digits (typical OTP length)
    if (trimmedOtp.length < 4 || trimmedOtp.length > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP (4-6 digits).')),
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
          if (state.reqId.isNotEmpty) {
            currentReqId = state.reqId;
          }
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
          appBar: AppBar(title: const Text('Verify OTP')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('OTP sent to ${widget.phone}'),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: 'XXXXXX',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => otp = v,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isVerifying ? null : _verifyOtp,
                  child: isVerifying
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: (secondsRemaining == 0 && !isResending)
                      ? _resendOtp
                      : null,
                  child: isResending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(secondsRemaining == 0
                          ? 'Resend OTP'
                          : 'Resend available in 00:${secondsRemaining.toString().padLeft(2, '0')}'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
