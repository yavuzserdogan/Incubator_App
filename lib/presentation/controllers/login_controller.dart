import 'package:get/get.dart';
import 'package:incubator/domain/entities/login_entity.dart';
import 'package:incubator/domain/use_case/auth/login_user.dart';
import '../../core/services/token_service.dart';
import '../../core/services/network_service.dart';
import '../../core/utils/text_files.dart';
import '../../data/models/user_model.dart';
import '../../data/sources/local/user_local_data_source.dart';
import '../components/snackbar_helper.dart';
import '../../core/errors.dart';

class LoginController extends GetxController {
  final LoginUser loginUserUseCase;
  final TokenService tokenService;
  final UserLocalDataSource localDataSource;
  final NetworkService networkService;

  var isLoading = false.obs;

  // var errorMessage = ''.obs;
  var token = ''.obs;
  var isPasswordVisible = true.obs;

  void passwordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  LoginController(
    this.loginUserUseCase,
    this.tokenService,
    this.localDataSource,
    this.networkService,
  );

  // Future<bool> login({required String email, required String password}) async {
  //   isLoading.value = true;
  //   try {
  //     if (email.isEmpty || password.isEmpty) {
  //       errorMessage.value = 'Email ve şifre boş olamaz';
  //       return false;
  //     }
  //
  //     final isConnected = await networkService.checkInternetConnection();
  //
  //     if (!isConnected) {
  //       print('İnternet bağlantısı yok, local DB kontrol ediliyor...');
  //       final UserModel? user = await localDataSource.getUserByEmail(email);
  //
  //       if (user == null) {
  //         errorMessage.value = 'Kullanıcı bulunamadı';
  //         return false;
  //       }
  //
  //       if (user.password != password) {
  //         errorMessage.value = 'Şifre yanlış';
  //         return false;
  //       }
  //       print("Local login başarılı.");
  //       await tokenService.saveLocalUserId(user.userId);
  //       print("Local user ID saved: ${user.userId}");
  //       return true;
  //     } else {
  //       print('İnternet bağlantısı var, server kontrol ediliyor...');
  //       try {
  //         final serverToken = await loginUserUseCase.call(
  //           LoginEntity(email: email, password: password),
  //         );
  //
  //         if (serverToken.isEmpty) {
  //           errorMessage.value = 'Server token alınamadı';
  //           return false;
  //         }
  //
  //         await tokenService.saveToken(serverToken);
  //         print('Server login başarılı. Token: $serverToken');
  //         return true;
  //       } catch (e) {
  //         errorMessage.value = 'Giriş başarısız: ${e.toString()}';
  //         return false;
  //       }
  //     }
  //   } catch (e, stacktrace) {
  //     errorMessage.value = e.toString();
  //     print("Stacktrace: $stacktrace");
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  //}
  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      if (email.isEmpty || password.isEmpty) {
        SnackBarHelper.showError(message: TextFiles.mailPassword);
        return false;
      }

      final isConnected = await networkService.checkInternetConnection();

      if (!isConnected) {
        final UserModel? user = await localDataSource.getUserByEmail(email);
        if (user == null) {
          SnackBarHelper.showError(message: TextFiles.userNotFound);
          return false;
        }
        if (user.password != password) {
          SnackBarHelper.showError(message: TextFiles.wrongPassword);
          return false;
        }
        await tokenService.saveLocalUserId(user.userId);
        SnackBarHelper.showInfo(message: TextFiles.login);
        return true;

      } else {
        try {
          final serverToken = await loginUserUseCase.call(
            LoginEntity(email: email, password: password),
          );

          if (serverToken.isEmpty) {
            SnackBarHelper.showError(message: TextFiles.serverError);
            return false;
          }

          await tokenService.saveToken(serverToken);
          SnackBarHelper.showInfo(message: TextFiles.loginSuccess);
          return true;
        } catch (e) {
          if (e is Failure) {
            final userMessage = ErrorHandler.getUserFriendlyMessage(e);
            print('🔍 DEBUG: Kullanıcı dostu mesaj: $userMessage');
            SnackBarHelper.showError(message: userMessage);
          } else {
            SnackBarHelper.showError(message: TextFiles.unknownError);
          }
          return false;
        }
        return true;
      }
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.unknownError);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
