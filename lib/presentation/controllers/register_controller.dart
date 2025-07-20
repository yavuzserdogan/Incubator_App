import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/services/token_service.dart';
import 'package:incubator/domain/entities/register_entity.dart';
import 'package:incubator/domain/use_case/auth/register_user.dart';
import 'package:incubator/domain/entities/user_entity.dart';
import 'package:incubator/domain/use_case/user/add_user.dart';
import '../../core/errors.dart';
import '../../core/utils/text_files.dart';
import '../components/snackbar_helper.dart';

class RegisterController extends GetxController {
  final RegisterUser registerUserUseCase;
  final TokenService tokenService;
  final AddUser addUserUseCase;

  RegisterController(
    this.registerUserUseCase,
    this.tokenService,
    this.addUserUseCase,
  );

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isPasswordVisible = true.obs;

  void passwordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> register({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final entity = RegisterEntity(
        name: name,
        surname: surname,
        email: email,
        password: password,
      );

      final response = await registerUserUseCase.call(entity);
      final responseData = response;
      final token = responseData['token'];
      final userId = responseData['userId'];

      await tokenService.saveToken(token);

      final user = User(
        userId: userId,
        name: name,
        surname: surname,
        email: email,
        password: password,
      );
      await addUserUseCase.call(user);

      SnackBarHelper.showInfo(message: TextFiles.registerSuccess);
    } catch (e) {
      if (e is Failure) {
        final userMessage = ErrorHandler.getUserFriendlyMessage(e);
        SnackBarHelper.showError(message: userMessage);
      } else {
        SnackBarHelper.showError(message: TextFiles.unknownError);
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
