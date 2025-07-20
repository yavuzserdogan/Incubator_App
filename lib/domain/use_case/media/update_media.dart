import 'package:incubator/domain/repositories/media_repositories.dart';

class UpdateMedia {
  final MediaRepository mediaRepository;

  UpdateMedia(this.mediaRepository);

  Future<void> call({
    required String mediaId,
    required String exerciseId,
    String? comments,
    String? updateAt,
    String? isSynced,
  }) async {
    await mediaRepository.updateMedia(
      mediaId: mediaId,
      exerciseId: exerciseId,
      comments: comments,
      updatedAt: updateAt,
      isSynced: isSynced,
    );
  }
}
