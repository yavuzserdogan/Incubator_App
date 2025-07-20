import 'package:incubator/domain/repositories/media_repositories.dart';

class DeleteMedia{
  final MediaRepository mediaRepository;

  DeleteMedia(this.mediaRepository);

  Future<void> call(String mediaId, String exerciseId) async {
    await mediaRepository.deleteMedia(mediaId, exerciseId);
  }
}