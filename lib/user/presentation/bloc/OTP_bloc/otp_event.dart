abstract class OtpEvent {}

class SendOtpEvent extends OtpEvent {
  final String phone;
  SendOtpEvent(this.phone);
}

class VerifyOtpEvent extends OtpEvent {
  final String reqId;
  final String otp;

  VerifyOtpEvent({required this.reqId, required this.otp});
}

class ResendOtpEvent extends OtpEvent {
  final String reqId;
  ResendOtpEvent(this.reqId);
}
