import 'package:incubator/domain/repositories/user_repositories.dart';
import 'package:incubator/domain/entities/user_entity.dart';

class GetUser {
  final UserRepository userRepository;
  GetUser(this.userRepository);

  Future<User?> call(String id) async {
    return await userRepository.getUser(id);
  }
}
