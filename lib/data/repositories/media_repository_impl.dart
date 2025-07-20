import 'package:incubator/data/sources/local/media_local_data_source.dart';
import 'package:incubator/domain/entities/media_entity.dart';
import 'package:incubator/domain/repositories/media_repositories.dart';
import 'package:get/get.dart';
import '../../core/services/token_service.dart';
import '../models/media_model.dart';
import '../sources/remote/media_remote_data_source.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class MediaRepositoryImpl implements MediaRepository {
  final MediaLocalDataSource localDataSource;
  final MediaRemoteDataSource remoteDataSource;
  final TokenService _tokenService = Get.find<TokenService>();

  MediaRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  //GET Medias
  @override
  Future<Media?> getMediaById(String mediaId) async {
    final mediaModels = await localDataSource.getMediaById(mediaId);
    return mediaModels?.toEntity();
  }

  @override
  Future<List<Media>> getMediaByExerciseId(String exerciseId) async {
    final mediaModels = await localDataSource.getMedia(exerciseId);
    return mediaModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Media>> getMediaBySynced(String userId) async {
    final currentUserId = _tokenService.currentUserId;
    if (currentUserId.isEmpty) {
      throw Exception('User not logged in');
    }
    final mediaModels = await localDataSource.getMediaBySynced(
      userId,
      //    isSynced,
    );
    return mediaModels.map((model) => model.toEntity()).toList();
  }

  //CREATE Media
  @override
  Future<void> createMedia(Media media, String exerciseId) async {
    final mediaModel = MediaModel.fromEntity(media);
    await localDataSource.createMedia(mediaModel, exerciseId);
  }

  //UPDATE Media
  @override
  Future<void> updateMedia({
    required String mediaId,
    required String exerciseId,
    String? comments,
    String? updatedAt,
    String? isSynced,
  }) async {
    await localDataSource.updateMedia(
      mediaId: mediaId,
      exerciseId: exerciseId,
      comments: comments,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  //DELETE Media
  @override
  Future<void> deleteMedia(String mediaId, String exerciseId) async {
    try {
      await localDataSource.deleteMedia(mediaId, exerciseId);

      final response = await remoteDataSource.deleteMedia(mediaId);

      print('Delete response: $response');
    } catch (e) {
      print('Repository: Delete error details: $e');
      if (e is Exception) {
        print('Repository: Exception type: ${e.runtimeType}');
        print('Repository: Exception message: ${e.toString()}');
      }

      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> syncMediasToServer(List<Media> medias) async {
    final syncData =
        medias
            .map((m) => {'localMediaId': m.mediaId, 'updatedAt': m.updatedAt})
            .toList();

    try {
      final response = await remoteDataSource.syncMedias(syncData);

      for (var medias in response.nonExistentLocalMedias) {
        if (medias['localMediaId'] == null ||
            medias['localExerciseId'] == null ||
            medias['comments'] == null ||
            medias['updatedAt'] == null ||
            medias['fileUrl'] == null) {
          continue;
        }

        // Download and save the image
        final fileUrl = medias['fileUrl'] as String;
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(fileUrl);
        final filePath = path.join(directory.path, fileName);

        try {
          final response = await http.get(Uri.parse(fileUrl));
          if (response.statusCode == 200) {
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            print('Image downloaded and saved to: $filePath');
          } else {
            print('Failed to download image: ${response.statusCode}');
            continue;
          }
        } catch (e) {
          print('Error downloading image: $e');
          continue;
        }

        await localDataSource.createMediaFromServer(
          mediaId: medias['localMediaId'] as String,
          exerciseId: medias['localExerciseId'] as String,
          comment: medias['comments'] as String,
          updatedAt: medias['updatedAt'] as String,
          filePath: filePath,
        );
      }

      if (response.nonExistentMedias.isNotEmpty) {
        await remoteDataSource.syncNonExistentMedias(
          response.nonExistentMedias,
        );
      }

      if (response.localNewerMedias.isNotEmpty) {
        await remoteDataSource.syncLocalNewerMedias(response.localNewerMedias);
      }

      if (response.serverNewerMedias.isNotEmpty) {
        await remoteDataSource.syncServerNewerMedias(
          response.serverNewerMedias,
        );
      }

      return {
        'non_existent_medias': response.nonExistentMedias,
        'non_existent_local_medias': response.nonExistentLocalMedias,
        'server_newer_medias': response.serverNewerMedias,
        'local_newer_medias': response.localNewerMedias,
      };
    } catch (e) {
      print('Sync error details: $e');
      throw Exception('Failed to sync medias: $e');
    }
  }
}
