import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:incubator/core/constants/api_constant.dart';
import 'dart:convert';
import '../../../core/errors.dart';
import '../../../core/utils/text_files.dart';
import '../../models/register_model.dart';
import '../../models/login_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register(RegisterModel model);

  Future<String> login(LoginModel model);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final backURL = ApiConstant.baseURL;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> register(RegisterModel model) async {
    try {
      final response = await client
          .post(
            Uri.parse('$backURL/Auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(model.toJson()),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw ServerFailure(
                message: ErrorMessages.serverError,
                code: ErrorCodes.serverError,
              );
            },
          );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'token': responseData['token'],
          'userId': responseData['userId'],
        };
      } else {
        try {
          final responseData = jsonDecode(response.body);
          final errorMessage =
              responseData['message'] ?? ErrorMessages.unknownError;
          throw ErrorHandler.handleHttpError(response.statusCode, errorMessage);
        } catch (e) {
          throw ServerFailure(
            message: TextFiles.serverError,
            code: ErrorCodes.serverError,
          );
        }
      }
    } on SocketException {
      throw NetworkFailure(
        message: ErrorMessages.networkError,
        code: ErrorCodes.networkError,
      );
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<String> login(LoginModel model) async {
    try {
      final response = await client
          .post(
            Uri.parse('$backURL/Auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(model.toJson()),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw ServerFailure(
                message: ErrorMessages.serverError,
                code: ErrorCodes.serverError,
              );
            },
          );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['token'];
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ?? ErrorMessages.unknownError;
        throw ErrorHandler.handleHttpError(response.statusCode, errorMessage);
      }
    } on SocketException catch (_) {
      throw NetworkFailure(
        message: ErrorMessages.networkError,
        code: ErrorCodes.networkError,
      );
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
