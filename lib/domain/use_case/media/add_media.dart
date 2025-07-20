import 'package:incubator/domain/entities/media_entity.dart';
import 'package:incubator/domain/repositories/media_repositories.dart';

class AddMedia {
  final MediaRepository mediaRepository;

  AddMedia(this.mediaRepository);

  Future<void> call(Media media, String exerciseId) async {
    await mediaRepository.createMedia(media, exerciseId);
  }
}