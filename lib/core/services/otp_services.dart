import 'dart:developer';

import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

class OtpService {
  final String widgetId = '366473693235373234343730';
  final String authToken = '509800TmgdopM9Gb69e4b13fP1';

  void init() {
    OTPWidget.initializeWidget(widgetId, authToken);
  }

Future<Map<String, dynamic>?> sendOtp(String phone) async {
  final identifier = phone.startsWith('91') ? phone : '91$phone';
  final data = {'identifier': identifier};
  log('Sending OTP with data: $data');
  return await OTPWidget.sendOTP(data);
}

  Future<Map<String, dynamic>?> verifyOtp(String reqId, String otp) async {
    final data = {'reqId': reqId, 'otp': otp};
    log('Verifying OTP with data: $data');
    return await OTPWidget.verifyOTP(data);
  }

  Future<Map<String, dynamic>?> retryOtp(String reqId) async {
    final data = {'reqId': reqId};
    log('Retrying OTP with data: $data');
    return await OTPWidget.retryOTP(data);
  }
}
