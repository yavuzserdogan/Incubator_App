import 'package:incubator/domain/entities/register_entity.dart';
import 'package:incubator/domain/repositories/auth_repositories.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Map<String, dynamic>> call(RegisterEntity user) async {
    return await repository.register(user);
  }
}