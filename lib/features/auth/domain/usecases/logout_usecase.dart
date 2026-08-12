import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;
  LogoutUsecase(this.repository);

  Future<void> call({bool allDevices = false}) {
    return allDevices ? repository.logoutFromAllDevices() : repository.logout();
  }
}