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
      if (response == null) {
        emit(OtpFailure('OTP service not initialized.'));
        return;
      }

      final reqId = _extractReqId(response);
      if (reqId.isEmpty) {
        emit(OtpFailure('OTP sent but no request id returned.'));
        return;
      }

      emit(OtpSent(phone: event.phone, reqId: reqId));
    } catch (error) {
      emit(OtpFailure('Send OTP failed: $error'));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpVerifyLoading());

    try {
      final response = await otpService.verifyOtp(event.reqId, event.otp);
      if (response != null && response['type'] == 'success') {
        emit(OtpVerified());
      } else {
        emit(OtpFailure(response?['message']?.toString() ?? 'Invalid OTP'));
      }
    } catch (error) {
      emit(OtpFailure('OTP verification failed: $error'));
    }
  }

  Future<void> _onResendOtp(ResendOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpResending());

    try {
      final response = await otpService.retryOtp(event.reqId);
      if (response == null) {
        emit(OtpFailure('OTP service not initialized.'));
        return;
      }

      final reqId = _extractReqId(response);
      if (reqId.isEmpty) {
        emit(OtpFailure('Resend OTP succeeded but no request id returned.'));
        return;
      }

      log('OTP resent successfully, new reqId: $reqId');
      emit(OtpResent(reqId: reqId));
    } catch (error) {
      emit(OtpFailure('Resend OTP failed: $error'));
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
}
