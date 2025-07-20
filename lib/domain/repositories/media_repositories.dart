import "package:incubator/domain/entities/media_entity.dart";

abstract class MediaRepository {

  Future<Media?> getMediaById(String mediaId);

  Future<List<Media>> getMediaByExerciseId(String exerciseId);

  Future<List<Media>> getMediaBySynced(String userId);

  Future<void> createMedia(Media media, String exerciseId);

  Future<void> updateMedia({
    required String mediaId,
    required String exerciseId,
    String? comments,
    String? updatedAt,
    String? isSynced,
  });

  Future<void> deleteMedia(String mediaId, String exerciseId);

  Future<Map<String, dynamic>> syncMediasToServer(List<Media> exercises);

}
