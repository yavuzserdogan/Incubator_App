import "package:incubator/domain/repositories/user_repositories.dart";

class DeleteUser {
  final UserRepository userRepository;
  DeleteUser(this.userRepository);

  Future<void> call(String id) async {
    await userRepository.deleteUser(id);
  }
}
