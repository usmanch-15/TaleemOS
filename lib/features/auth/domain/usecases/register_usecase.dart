import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;
  RegisterUsecase(this.repository);

  Future<void> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String schoolCode,
  }) {
    return repository.registerWithEmail(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
      schoolCode: schoolCode,
    );
  }
}