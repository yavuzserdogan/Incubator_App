import 'package:incubator/domain/entities/exercises_entity.dart';
import 'package:incubator/domain/repositories/exercises_repositories.dart';

class AddExercises{

final ExercisesRepository exercisesRepository;
  AddExercises(this.exercisesRepository);

  Future<void> call(Exercises exercise, String userId) async {
    await exercisesRepository.createExercise(exercise, userId);
  }

}