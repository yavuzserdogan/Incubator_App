import "package:incubator/domain/entities/user_entity.dart";

abstract class UserRepository{
    Future<User?> getUser(String userId);
    Future<void> createUser(User user);
    Future<void> updateUser(User user);
    Future<void> deleteUser(String id);
  }
  