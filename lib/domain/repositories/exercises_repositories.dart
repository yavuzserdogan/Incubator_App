import "package:incubator/domain/entities/exercises_entity.dart";

abstract class ExercisesRepository {
  Future<List<Exercises>> getExercise(String userId);

  Future<Exercises?> getExerciseById(String exerciseId);

  Future<List<Exercises>> getExerciseBySynced(String userId);

  Future<void> createExercise(Exercises exerciseId, String userId);

  Future<void> updateExercise({
    required String exerciseId,
    required String userId,
    String? title,
    String? endDateTime,
    String? updatedAt,
    String? isSynced,
  });

  Future<void> deleteExercise(String exerciseId, String userId);

  Future<List<Exercises>> getSyncedExercises();

  Future<Map<String, dynamic>> syncExercisesToServer(List<Exercises> exercises);
}
