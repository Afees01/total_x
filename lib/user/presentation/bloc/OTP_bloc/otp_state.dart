abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpSending extends OtpState {}

class OtpSent extends OtpState {
  final String phone;
  final String reqId;

  OtpSent({required this.phone, required this.reqId});
}

class OtpVerifyLoading extends OtpState {}

class OtpVerified extends OtpState {}

class OtpResending extends OtpState {}

class OtpResent extends OtpState {
  final String reqId;

  OtpResent({required this.reqId});
}

class OtpFailure extends OtpState {
  final String message;
  OtpFailure(this.message);
}
