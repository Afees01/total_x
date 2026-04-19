import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final trimmedPhone = phone.trim();

    // Check if phone number is empty
    if (trimmedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    // Check if phone number contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Phone number should contain only digits.')),
      );
      return;
    }

    // Check if phone number is exactly 10 digits (for Indian mobile numbers)
    if (trimmedPhone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit mobile number.')),
      );
      return;
    }

    // Check if phone number starts with valid Indian mobile prefixes (optional but good practice)
    final validPrefixes = ['6', '7', '8', '9'];
    if (!validPrefixes.contains(trimmedPhone[0])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter a valid Indian mobile number starting with 6, 7, 8, or 9.')),
      );
      return;
    }

    final formattedPhone = '91$trimmedPhone';

    context.read<OtpBloc>().add(SendOtpEvent(formattedPhone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpPage(
                phone: state.phone,
                reqId: state.reqId,
              ),
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
            appBar: AppBar(title: const Text('Login')),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter 10-digit mobile number',
                      counterText: '',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        phone = value.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSending ? null : () => _sendOtp(context),
                    child: isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send OTP'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
