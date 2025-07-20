import "package:incubator/domain/repositories/exercises_repositories.dart";

class UpdateExercises {
  final ExercisesRepository exercisesRepository;
  UpdateExercises(this.exercisesRepository);

  Future<void> call({
    required String exerciseId,
    required String userId,
    String? title,
    String? endDateTime,
    String? updatedAt,
    String? isSynced,
  }) async {
    await exercisesRepository.updateExercise(
      exerciseId: exerciseId,
      userId: userId,
      title: title,
      endDateTime: endDateTime,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }
}