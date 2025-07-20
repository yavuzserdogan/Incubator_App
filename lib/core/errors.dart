import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

class ErrorMessages {
  static const String serverError = 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String cacheError = 'Önbellek hatası oluştu.';
  static const String networkError = 'İnternet bağlantınızı kontrol edin.';
  static const String validationError = 'Geçersiz veri girişi.';
  static const String authenticationError = 'Kimlik doğrulama hatası.';
  static const String authorizationError = 'Yetkilendirme hatası.';
  static const String unknownError = 'Beklenmeyen bir hata oluştu.';
}

class ErrorCodes {
  static const String serverError = 'SERVER_ERROR';
  static const String cacheError = 'CACHE_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String authenticationError = 'AUTHENTICATION_ERROR';
  static const String authorizationError = 'AUTHORIZATION_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
}


class ErrorHandler {
  /// HTTP status code'a göre uygun Failure tipini döndürür
  static Failure handleHttpError(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ValidationFailure(
          message: message,
          code: ErrorCodes.validationError,
        );
      case 401:
        return AuthenticationFailure(
          message: message,
          code: ErrorCodes.authenticationError,
        );
      case 403:
        return AuthorizationFailure(
          message: message,
          code: ErrorCodes.authorizationError,
        );
      case 404:
        return ServerFailure(
          message: message,
          code: ErrorCodes.serverError,
        );
      case 500:
      case 502:
      case 503:
        return ServerFailure(
          message: message,
          code: ErrorCodes.serverError,
        );
      default:
        return ServerFailure(
          message: message,
          code: ErrorCodes.serverError,
        );
    }
  }

  /// Exception'a göre uygun Failure tipini döndürür
  static Failure handleException(dynamic error) {
    if (error is Failure) {
      return error;
    }

    if (error.toString().contains('SocketException')) {
      return NetworkFailure(
        message: ErrorMessages.networkError,
        code: ErrorCodes.networkError,
      );
    }

    if (error.toString().contains('TimeoutException')) {
      return ServerFailure(
        message: 'İstek zaman aşımına uğradı',
        code: ErrorCodes.serverError,
      );
    }

    return UnknownFailure(
      message: ErrorMessages.unknownError,
      code: ErrorCodes.unknownError,
    );
  }

  /// Kullanıcı dostu mesaj döndürür
  static String getUserFriendlyMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      if (failure.message.toLowerCase().contains('invalid password')) {
        return 'Şifre yanlış';
      }
      if (failure.message.toLowerCase().contains('user not found')) {
        return 'Kullanıcı bulunamadı';
      }
      if (failure.message.toLowerCase().contains('email')) {
        return 'Geçersiz email adresi';
      }
      return 'Giriş bilgileri hatalı';
    }

    if (failure is ValidationFailure) {
      if (failure.message.toLowerCase().contains('email')) {
        return 'Geçersiz email formatı';
      }
      if (failure.message.toLowerCase().contains('password')) {
        return 'Şifre gereksinimleri karşılanmıyor';
      }

      if (failure.message.toLowerCase().contains('user already exists')) {
        return 'Bu email adresi zaten kayıtlı';
      }
      if (failure.message.toLowerCase().contains('name') ||
          failure.message.toLowerCase().contains('surname')) {
        return 'İsim ve soyisim alanları zorunludur';
      }
      return 'Geçersiz veri girişi';
    }

    return failure.message;
  }
}