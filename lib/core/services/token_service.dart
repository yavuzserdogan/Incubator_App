import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class TokenService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final token = ''.obs;
  final userId = ''.obs;

  Future<void> init() async {
    try {
      final storedToken = await _storage.read(key: 'auth_token') ?? '';
      token.value = storedToken;

      if (storedToken.isNotEmpty) {
        userId.value = await _getUserIdFromToken(storedToken);
      }
    } catch (e) {
      token.value = '';
      userId.value = '';
    }
  }

  Future<void> saveToken(String newToken) async {
    await _storage.write(key: 'auth_token', value: newToken);
    token.value = newToken;
    userId.value = await _getUserIdFromToken(newToken);
  }

  Future<void> deleteToken() async {
    await clearSessionData();
  }

  Future<void> clearSessionData() async {
    try {
      // Sadece token ve oturum bilgilerini temizle
      await _storage.delete(key: 'auth_token');
      token.value = '';
      userId.value = '';
    } catch (e) {}
  }

  Future<void> saveLocalUserId(String userId) async {
    await _storage.write(key: 'auth_token', value: userId);
    token.value = userId;
    this.userId.value = userId;
  }

  Future<String> _getUserIdFromToken(String token) async {
    try {
      if (token.isEmpty) {
        return '';
      }

      // Eğer token bir JWT değilse (local giriş), direkt token'ı user ID olarak kullan
      if (!token.contains('.')) {
        return token;
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        return '';
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      final userId = payloadMap['sub'] as String? ?? '';

      return userId;
    } catch (e) {
      return '';
    }
  }

  String get currentUserId => userId.value;
}
