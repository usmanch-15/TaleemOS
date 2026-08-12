import '../repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository repository;
  ForgotPasswordUsecase(this.repository);

  Future<void> call(String email) => repository.sendPasswordResetEmail(email);
}