import "package:incubator/domain/entities/user_entity.dart";
import "package:incubator/domain/repositories/user_repositories.dart";

class UpdateUser {
  final UserRepository userRepository;
  UpdateUser(this.userRepository);

  Future<void> call(User user) async {
    await userRepository.updateUser(user);
  }
}
