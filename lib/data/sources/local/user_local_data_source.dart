import 'package:sqflite/sqflite.dart';
import '../../models/user_model.dart';
import 'package:incubator/data/sources/local/database/database_helper.dart';

abstract class UserLocalDataSource {
  Future<void> createUser(UserModel user);

  Future<UserModel?> getUser(String userId);

  Future<UserModel?> getUserByEmail(String email);

  Future<void> updateUser(UserModel user);

  Future<void> deleteUser(String userId);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isValidUUID(String uuid) {
    final regex = RegExp(
      r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[4][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$",
    );
    return regex.hasMatch(uuid);
  }

  @override
  Future<void> createUser(UserModel user) async {
    final db = await _dbHelper.database;

    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    if (!_isValidUUID(userId)) throw FormatException("Invalid UUID format");

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    if (!_isValidUUID(user.userId)) throw FormatException("Invalid UUID format");

    final db = await _dbHelper.database;
    final count = await db.update(
      'users',
      user.toJson(),
      where: 'userId = ?',
      whereArgs: [user.userId],
    );

    if (count == 0) {
      throw Exception("User not found");
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    if (!_isValidUUID(userId)) throw FormatException("Invalid UUID format");

    final db = await _dbHelper.database;
    final count = await db.delete('users', where: 'userId = ?', whereArgs: [userId]);

    if (count == 0) {
      throw Exception("User not found");
    }
  }
}
