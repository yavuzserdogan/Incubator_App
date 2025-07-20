import 'package:incubator/data/sources/local/exercises_local_data_source.dart';
import 'package:incubator/domain/entities/exercises_entity.dart';
import 'package:incubator/domain/repositories/exercises_repositories.dart';
import '../models/exercise_model.dart';
import 'package:get/get.dart';
import '../sources/remote/exercise_remote_data_source.dart';
import 'package:incubator/core/services/token_service.dart';

import '../sources/remote/media_remote_data_source.dart';

class ExercisesRepositoryImpl implements ExercisesRepository {
  final ExercisesRemoteDataSource remoteDataSourceExercise;
  final MediaRemoteDataSource remoteDataSourceMedia;
  final ExercisesLocalDataSource localDataSource;
  final TokenService _tokenService = Get.find<TokenService>();

  ExercisesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSourceExercise,
    required this.remoteDataSourceMedia,
  });

  //GET Exercises
  @override
  Future<List<Exercises>> getExercise(String userId) async {
    final exerciseModels = await localDataSource.getExercises(userId);
    return exerciseModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Exercises?> getExerciseById(String exerciseId) async {
    final exerciseModel = await localDataSource.getExerciseById(exerciseId);
    return exerciseModel?.toEntity();
  }

  // ???
  @override
  Future<List<Exercises>> getSyncedExercises() async {
    final currentUserId = _tokenService.currentUserId;
    if (currentUserId.isEmpty) {
      throw Exception('User not logged in');
    }
    final syncedExercises = await localDataSource.getExercises(currentUserId);
    return syncedExercises.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Exercises>> getExerciseBySynced(
    String userId,
    //bool isSynced,
  ) async {
    final exerciseModels = await localDataSource.getExercisesBySynced(userId);
    return exerciseModels.map((model) => model.toEntity()).toList();
  }

  //CREATE Exercise
  @override
  Future<void> createExercise(Exercises exercise, String userId) async {
    final exerciseModel = ExerciseModel.fromEntity(exercise);
    await localDataSource.createExercise(exerciseModel);
  }

  //UPDATE Exercises
  @override
  Future<void> updateExercise({
    required String exerciseId,
    required String userId,
    String? title,
    String? endDateTime,
    String? updatedAt,
    String? isSynced,
  }) async {
    await localDataSource.updateExercise(
      exerciseId: exerciseId,
      userId: userId,
      title: title,
      endDateTime: endDateTime,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  //DELETE Exercise
  @override
  Future<void> deleteExercise(String exerciseId, String userId) async {
    try {
      await localDataSource.deleteExercise(exerciseId);
      final responseExercise = await remoteDataSourceExercise.deleteExercise(
        exerciseId,
      );
      print('Delete response: $responseExercise');
    } catch (e) {
      print('Delete error in repository: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> syncExercisesToServer(
    List<Exercises> exercises,
  ) async {
    final syncData =
        exercises
            .map((e) => {'exerciseId': e.exerciseId, 'updatedAt': e.updatedAt})
            .toList();
    try {
      final response = await remoteDataSourceExercise.syncExercises(syncData);

      for (var exercise in response.nonExistentLocalExercises) {
        if (exercise['localExerciseId'] == null ||
            exercise['title'] == null ||
            exercise['startDateTime'] == null ||
            exercise['endDateTime'] == null ||
            exercise['updatedAt'] == null) {
          continue;
        }
        await localDataSource.createExerciseFromServer(
          exerciseId: exercise['localExerciseId'] as String,
          userId: _tokenService.currentUserId,
          title: exercise['title'] as String,
          startDateTime: exercise['startDateTime'] as String,
          endDateTime: exercise['endDateTime'] as String,
          updatedAt: exercise['updatedAt'] as String,
        );
      }

      if (response.nonExistentExercises.isNotEmpty) {
        await remoteDataSourceExercise.syncNonExistentExercises(
          response.nonExistentExercises,
        );
      }

      if (response.localNewerExercises.isNotEmpty) {
        await remoteDataSourceExercise.syncLocalNewerExercises(
          response.localNewerExercises,
        );
      }

      if (response.serverNewerExercises.isNotEmpty) {
        await remoteDataSourceExercise.syncServerNewerExercises(
          response.serverNewerExercises,
        );
      }

      return {
        'non_existent_exercises': response.nonExistentExercises,
        'non_existent_local_exercises': response.nonExistentLocalExercises,
        'server_newer_exercises': response.serverNewerExercises,
        'local_newer_exercises': response.localNewerExercises,
      };
    } catch (e) {
      throw Exception('Failed to sync exercises: $e');
    }
  }
}
