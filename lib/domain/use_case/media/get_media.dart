import 'package:incubator/domain/entities/media_entity.dart';
import 'package:incubator/domain/repositories/media_repositories.dart';

class GetMedia {
  final MediaRepository mediaRepository;

  GetMedia(this.mediaRepository);

  Future<List<Media>> call(String exerciseId) async {
    return await mediaRepository.getMediaByExerciseId(exerciseId);
  }
}