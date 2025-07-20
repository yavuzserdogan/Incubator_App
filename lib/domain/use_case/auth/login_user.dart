import 'package:incubator/domain/entities/login_entity.dart';
import 'package:incubator/domain/repositories/auth_repositories.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<String> call(LoginEntity entity) async {
    return await repository.login(entity);
  }
}
