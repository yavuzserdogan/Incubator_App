import 'package:uuid/uuid.dart';

class IdGenerator {
  static final _uuid = Uuid();

  static String generateTimeBasedId() {
    return _uuid.v1();
  }

  static bool isValidUUID(String uuid) {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(uuid);
  }
}
