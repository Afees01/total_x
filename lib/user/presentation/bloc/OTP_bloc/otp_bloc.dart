import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:total_x/core/services/otp_services.dart';

import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final OtpService otpService;

  OtpBloc(this.otpService) : super(OtpInitial()) {
    otpService.init();

    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpSending());

    try {
      final response = await otpService.sendOtp(event.phone);
      log('OTP send response: $response');
      if (response == null) {
        emit(OtpFailure(
            'Unable to connect to OTP service. Please check your internet connection.'));
        return;
      }

      if (response['type'] != 'success') {
        final errorMessage =
            _getMeaningfulErrorMessage(response['message']?.toString());
        emit(OtpFailure(errorMessage));
        return;
      }

      final reqId = _extractReqId(response);
      if (reqId.isEmpty) {
        emit(OtpFailure(
            'OTP request was sent but we couldn\'t get a confirmation. Please try again.'));
        return;
      }

      emit(OtpSent(phone: event.phone, reqId: reqId));
    } catch (error) {
      log('OTP send error: $error');
      emit(OtpFailure(
          'Failed to send OTP. Please check your internet connection and try again.'));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpVerifyLoading());

    try {
      final response = await otpService.verifyOtp(event.reqId, event.otp);
      log('OTP verify response: $response');
      if (response != null && response['type'] == 'success') {
        emit(OtpVerified());
      } else {
        final errorMessage =
            _getMeaningfulErrorMessage(response?['message']?.toString());
        emit(OtpFailure(errorMessage));
      }
    } catch (error) {
      log('OTP verify error: $error');
      emit(OtpFailure(
          'Failed to verify OTP. Please check your internet connection and try again.'));
    }
  }

  Future<void> _onResendOtp(
      ResendOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpResending());

    try {
      final response = await otpService.retryOtp(event.reqId);
      log('OTP resend response: $response');
      if (response == null) {
        emit(OtpFailure(
            'Unable to connect to OTP service. Please check your internet connection.'));
        return;
      }

      if (response['type'] != 'success') {
        final errorMessage =
            _getMeaningfulErrorMessage(response['message']?.toString());
        emit(OtpFailure(errorMessage));
        return;
      }

      final reqId = _extractReqId(response);
      if (reqId.isEmpty) {
        emit(OtpFailure(
            'OTP was resent but we couldn\'t get a confirmation. Please try again.'));
        return;
      }

      log('OTP resent successfully, new reqId: $reqId');
      emit(OtpResent(reqId: reqId));
    } catch (error) {
      log('OTP resend error: $error');
      emit(OtpFailure(
          'Failed to resend OTP. Please check your internet connection and try again.'));
    }
  }

  String _extractReqId(Map<String, dynamic> response) {
    final requestData = response['data'];

    if (response['reqId'] != null) {
      return response['reqId'].toString();
    }
    if (response['requestId'] != null) {
      return response['requestId'].toString();
    }
    if (response['request_id'] != null) {
      return response['request_id'].toString();
    }
    if (response['message'] != null && response['message'] is String) {
      return response['message'];
    }

    if (requestData is Map) {
      if (requestData['reqId'] != null) {
        return requestData['reqId'].toString();
      }
      if (requestData['requestId'] != null) {
        return requestData['requestId'].toString();
      }
      if (requestData['request_id'] != null) {
        return requestData['request_id'].toString();
      }
      if (requestData['message'] != null && requestData['message'] is String) {
        return requestData['message'];
      }
    }

    return '';
  }

  String _getMeaningfulErrorMessage(String? rawMessage) {
    if (rawMessage == null || rawMessage.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    final message = rawMessage.toLowerCase();

    // Common OTP service error mappings
    if (message.contains('ipblocked') || message.contains('ip blocked')) {
      return 'Too many requests from your device. Please wait a few minutes before trying again.';
    }

    if (message.contains('invalid') && message.contains('phone')) {
      return 'Please enter a valid phone number.';
    }

    if (message.contains('expired') || message.contains('timeout')) {
      return 'OTP has expired. Please request a new one.';
    }

    if (message.contains('invalid') && message.contains('otp')) {
      return 'Incorrect OTP. Please check the code and try again.';
    }

    if (message.contains('limit') || message.contains('exceeded')) {
      return 'You\'ve reached the maximum number of attempts. Please try again later.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'Network connection failed. Please check your internet and try again.';
    }

    if (message.contains('service') && message.contains('unavailable')) {
      return 'OTP service is temporarily unavailable. Please try again in a few minutes.';
    }

    if (message.contains('blocked') || message.contains('suspended')) {
      return 'Your account has been temporarily blocked. Please contact support.';
    }

    // If we can't map it to a known error, return a generic but helpful message
    return 'Failed to process your request. Please try again or contact support if the problem persists.';
  }
}
