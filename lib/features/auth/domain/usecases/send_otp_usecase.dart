import '../repositories/auth_repository.dart';

class SendOtpUsecase {
  final AuthRepository repository;
  SendOtpUsecase(this.repository);

  Future<void> call(String phone) => repository.sendPhoneOtp(phone);
}