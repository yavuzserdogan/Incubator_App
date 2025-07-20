import 'package:incubator/domain/entities/exercises_entity.dart';
import 'package:incubator/domain/repositories/exercises_repositories.dart';

class GetExercises {
  final ExercisesRepository exercisesRepository;
  GetExercises(this.exercisesRepository);

  Future<List<Exercises>> call(String userId) async {
    return await exercisesRepository.getExercise(userId);
  }
}