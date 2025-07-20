import 'package:incubator/domain/repositories/exercises_repositories.dart';
import '../../entities/exercises_entity.dart';

class GetExercisesBySynced {
  final ExercisesRepository exercisesRepository;

  GetExercisesBySynced(this.exercisesRepository);

  Future<List<Exercises>> call(String userId) async {
    return await exercisesRepository.getExerciseBySynced(userId);
  }
}
