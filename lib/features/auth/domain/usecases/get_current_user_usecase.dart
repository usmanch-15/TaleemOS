import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;
  GetCurrentUserUsecase(this.repository);

  Future<UserEntity?> call() => repository.getCurrentUser();
}