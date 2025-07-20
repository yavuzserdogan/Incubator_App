import "package:incubator/domain/repositories/exercises_repositories.dart";

class DeleteExercises {
  final ExercisesRepository exercisesRepository;
  DeleteExercises(this.exercisesRepository);

  Future<void> call(String exerciseId, String userId) async {
    await exercisesRepository.deleteExercise(exerciseId, userId);
  }
}