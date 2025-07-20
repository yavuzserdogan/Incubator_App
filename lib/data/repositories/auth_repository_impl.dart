import 'package:incubator/data/models/register_model.dart';
import 'package:incubator/data/sources/remote/auth_remote_data_source.dart';
import 'package:incubator/domain/entities/register_entity.dart';
import 'package:incubator/domain/repositories/auth_repositories.dart';
import 'package:incubator/domain/entities/login_entity.dart';
import 'package:incubator/data/models/login_model.dart';

import '../../core/errors.dart';
import '../../core/services/network_service.dart';
import '../sources/local/user_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkService networkService;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource, this.networkService);

  @override
  Future<String> login(LoginEntity entity) async {
    final model = LoginModel(email: entity.email, password: entity.password);

    // İnternet bağlantısını kontrol et
    final isConnected = await networkService.checkInternetConnection();

    if (!isConnected) {
      // Local veritabanından kullanıcıyı kontrol et
      final user = await localDataSource.getUserByEmail(entity.email);
      if (user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }
      if (user.password != entity.password) {
        throw Exception('Şifre yanlış');
      }
      return user.userId;
    }

    try {
      return await remoteDataSource.login(model);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register(RegisterEntity entity) async {
    final model = RegisterModel(
      name: entity.name,
      surname: entity.surname,
      email: entity.email,
      password: entity.password,
    );
    return await remoteDataSource.register(model);
  }
}
