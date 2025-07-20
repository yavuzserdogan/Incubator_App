import "package:incubator/domain/entities/user_entity.dart";
import "package:incubator/domain/repositories/user_repositories.dart";

class AddUser {
  final UserRepository userRepository;
  AddUser(this.userRepository);

  Future<void> call(User user) async {
    await userRepository.createUser(user);
  }
}
