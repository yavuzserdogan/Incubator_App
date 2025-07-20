import 'package:incubator/domain/repositories/user_repositories.dart';
import 'package:incubator/data/sources/local/user_local_data_source.dart';
import 'package:incubator/data/models/user_model.dart';
import 'package:incubator/domain/entities/user_entity.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;
  
  UserRepositoryImpl(this.localDataSource);

  @override
  Future<User?> getUser(String userId) async {
    final userModel = await localDataSource.getUser(userId);
    return userModel?.toEntity();
  }

  @override
  Future<void> createUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await localDataSource.createUser(userModel);
  }

  @override
  Future<void> updateUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await localDataSource.updateUser(userModel);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await localDataSource.deleteUser(userId);
  }
}