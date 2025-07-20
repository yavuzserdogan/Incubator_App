import 'package:incubator/domain/entities/login_entity.dart';
import 'package:incubator/domain/entities/register_entity.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> register(RegisterEntity entity);
  Future<String> login(LoginEntity entity);
}