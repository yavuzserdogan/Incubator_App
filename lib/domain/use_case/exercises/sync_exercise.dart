import 'package:incubator/domain/repositories/exercises_repositories.dart';

class SyncExercises {
  final ExercisesRepository repository;

  SyncExercises(this.repository);

  Future<void> execute() async {
    final syncedExercises = await repository.getSyncedExercises();

    if (syncedExercises.isNotEmpty) {
      await repository.syncExercisesToServer(syncedExercises);
    }
  }
}
