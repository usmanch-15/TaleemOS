import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository repository;
  VerifyOtpUsecase(this.repository);

  Future<UserEntity> call({required String phone, required String otp}) {
    return repository.verifyPhoneOtp(phone: phone, otp: otp);
  }
}