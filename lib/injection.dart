import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:incubator/domain/repositories/user_repositories.dart';
import 'package:incubator/domain/use_case/exercises/add_exercises.dart';
import 'package:incubator/domain/use_case/user/add_user.dart';
import 'package:incubator/domain/use_case/user/delete_user.dart';
import 'package:incubator/domain/use_case/user/get_user.dart';
import 'package:incubator/domain/use_case/user/update_user.dart';
import 'package:incubator/presentation/controllers/experiment_controller.dart';
import 'package:incubator/presentation/controllers/media_controller.dart';
import 'package:incubator/presentation/controllers/page_controller.dart';
import 'package:incubator/presentation/controllers/register_controller.dart';
import 'package:incubator/domain/use_case/auth/register_user.dart';
import 'package:incubator/data/sources/remote/auth_remote_data_source.dart';
import 'package:incubator/data/repositories/auth_repository_impl.dart';
import 'package:incubator/domain/repositories/auth_repositories.dart';
import 'package:incubator/domain/use_case/auth/login_user.dart';
import 'package:incubator/presentation/controllers/login_controller.dart';
import 'core/services/network_service.dart';
import 'core/services/token_service.dart';
import 'data/repositories/exercises_repository_impl.dart';
import 'data/repositories/media_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/sources/local/exercises_local_data_source.dart';
import 'data/sources/local/media_local_data_source.dart';
import 'data/sources/local/user_local_data_source.dart';
import 'data/sources/remote/exercise_remote_data_source.dart';
import 'data/sources/remote/media_remote_data_source.dart';
import 'domain/repositories/exercises_repositories.dart';
import 'domain/repositories/media_repositories.dart';
import 'domain/use_case/exercises/delete_exercises.dart';
import 'domain/use_case/exercises/get_exercises.dart';
import 'domain/use_case/exercises/update_exercises.dart';

Future<void> initDependencies() async {
  // TokenService
  await Get.putAsync<TokenService>(() async {
    final service = TokenService();
    await service.init();
    return service;
  });

  // NetworkService
  Get.put(NetworkService());

  // Http client
  Get.lazyPut<http.Client>(() => http.Client());

  // data source
  Get.lazyPut<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(Get.find<http.Client>()),
  );

  Get.lazyPut<ExercisesLocalDataSource>(() => ExerciseLocalDataSourceImpl());

  Get.lazyPut<ExercisesRemoteDataSource>(
    () => ExercisesRemoteDataSourceImpl(client: Get.find<http.Client>()),
  );

  Get.lazyPut<UserLocalDataSource>(() => UserLocalDataSourceImpl());

  Get.lazyPut<MediaLocalDataSource>(() => MediaLocalDataSourcesImpl());

  Get.lazyPut<MediaRemoteDataSource>(
    () => MediaRemoteDataSourceImpl(client: Get.find<http.Client>()),
  );

  // Repository (interface + implementation)
  Get.lazyPut<AuthRepository>(
    () => AuthRepositoryImpl(
      Get.find<AuthRemoteDataSource>(),
      Get.find<UserLocalDataSource>(),
      Get.find<NetworkService>(),
    ),
  );

  Get.lazyPut<UserRepository>(
    () => UserRepositoryImpl(Get.find<UserLocalDataSource>()),
  );

  Get.lazyPut<ExercisesRepository>(
    () => ExercisesRepositoryImpl(
      localDataSource: Get.find<ExercisesLocalDataSource>(),
      remoteDataSourceExercise: Get.find<ExercisesRemoteDataSource>(),
      remoteDataSourceMedia: Get.find<MediaRemoteDataSource>(),
    ),
  );
  Get.lazyPut<MediaRepository>(
    () => MediaRepositoryImpl(
      localDataSource: Get.find<MediaLocalDataSource>(),
      remoteDataSource: Get.find<MediaRemoteDataSource>(),
    ),
  );

  // UseCase
  Get.lazyPut(() => RegisterUser(Get.find<AuthRepository>()));
  Get.lazyPut(() => LoginUser(Get.find<AuthRepository>()));

  Get.lazyPut(() => AddUser(Get.find<UserRepository>()));
  Get.lazyPut(() => GetUser(Get.find<UserRepository>()));
  Get.lazyPut(() => UpdateUser(Get.find<UserRepository>()));
  Get.lazyPut(() => DeleteUser(Get.find<UserRepository>()));

  Get.lazyPut(() => GetExercises(Get.find<ExercisesRepository>()));
  Get.lazyPut(() => AddExercises(Get.find<ExercisesRepository>()));
  Get.lazyPut(() => UpdateExercises(Get.find<ExercisesRepository>()));
  Get.lazyPut(() => DeleteExercises(Get.find<ExercisesRepository>()));

  // Controller
  Get.lazyPut(
    () => RegisterController(
      Get.find<RegisterUser>(),
      Get.find<TokenService>(),
      Get.find<AddUser>(),
    ),
  );

  Get.lazyPut(
    () => LoginController(
      Get.find<LoginUser>(),
      Get.find<TokenService>(),
      Get.find<UserLocalDataSource>(),
      Get.find<NetworkService>(),
    ),
  );

  Get.lazyPut(() => PagesController());

  Get.lazyPut(
    () => ExperimentController(
      Get.find<ExercisesRepository>(),
      Get.find<TokenService>(),
      Get.find<NetworkService>(),
    ),
  );

  Get.put<MediaController>(
    MediaController(
      Get.find<MediaRepository>(),
      Get.find<TokenService>(),
      Get.find<NetworkService>(),
    ),
  );
}
