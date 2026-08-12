import '../repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository repository;
  ResetPasswordUsecase(this.repository);

  Future<void> call(String newPassword) => repository.updatePassword(newPassword);
}