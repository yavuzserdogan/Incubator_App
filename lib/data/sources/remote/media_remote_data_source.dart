import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:incubator/core/constants/api_constant.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:incubator/core/services/token_service.dart';
import 'package:incubator/data/dto/media/media_upload_dto.dart';
import 'package:incubator/data/dto/media/media_create_response_dto.dart';
import '../../dto/media/media_update_response_dto.dart';
import '../local/media_local_data_source.dart';

class SyncResponse {
  final List<Map<String, dynamic>> nonExistentMedias;
  final List<Map<String, dynamic>> serverNewerMedias;
  final List<Map<String, dynamic>> localNewerMedias;
  final List<Map<String, dynamic>> nonExistentLocalMedias;

  SyncResponse({
    required this.nonExistentMedias,
    required this.serverNewerMedias,
    required this.localNewerMedias,
    required this.nonExistentLocalMedias,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {

    final nonExistentMedias = List<Map<String, dynamic>>.from(
      json['nonExistentMedia'] ?? [],
    );

    final serverNewerMedias = List<Map<String, dynamic>>.from(
      json['serverNewerMedia'] ?? [],
    );

    final localNewerMedias = List<Map<String, dynamic>>.from(
      json['localNewerMedia'] ?? [],
    );

    final nonExistentLocalMedias = List<Map<String, dynamic>>.from(
      json['nonExistentLocalMedia'] ?? [],
    );

    return SyncResponse(
      nonExistentMedias: nonExistentMedias,
      serverNewerMedias: serverNewerMedias,
      localNewerMedias: localNewerMedias,
      nonExistentLocalMedias: nonExistentLocalMedias,
    );
  }
}

abstract class MediaRemoteDataSource {
  Future<SyncResponse> syncMedias(List<Map<String, dynamic>> medias);

  Future<MediaCreateResponseDto> createMedia(
    MediaUploadDto dto,
    String filePath,
  );

  Future<void> syncNonExistentMedias(
    List<Map<String, dynamic>> nonExistentMedias,
  );

  Future<void> syncLocalNewerMedias(
    List<Map<String, dynamic>> localNewerMedias,
  );

  Future<void> syncServerNewerMedias(
    List<Map<String, dynamic>> serverNewerMedias,
  );

  Future<Map<String, dynamic>> deleteMedia(String mediaId);

  Future<MediaUpdateResponseDto> updateMedia(String mediaId, String comment);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final http.Client client;
  final TokenService _tokenService = Get.find<TokenService>();
  final backURL = ApiConstant.baseURL;
  final MediaLocalDataSource localDataSource = Get.find<MediaLocalDataSource>();

  MediaRemoteDataSourceImpl({required this.client});

  @override
  Future<SyncResponse> syncMedias(List<Map<String, dynamic>> medias) async {
    final token = _tokenService.token.value;

    if (token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await client.post(
      Uri.parse('$backURL/Media/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(medias),
    );


    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sync medias');
    }

    final responseData = jsonDecode(response.body);

    final syncResponse = SyncResponse.fromJson(responseData);


    return syncResponse;
  }

  @override
  Future<MediaCreateResponseDto> createMedia(
    MediaUploadDto dto,
    String filePath,
  ) async {
    final token = _tokenService.token.value;
    if (token.isEmpty) throw Exception('No authentication token found');

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$backURL/Media'));

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'FileName': dto.fileName,
        'Comments': dto.comments,
        'LocalMediaId': dto.localMediaId,
        'ExerciseId': dto.exerciseId,
      });

      // Add file
      final file = File(filePath);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'File',
            filePath,
            filename: dto.fileName,
          ),
        );
      } else {
        throw Exception('File does not exist: $filePath');
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create media: ${response.body}');
      }


      final Map<String, dynamic> json = jsonDecode(response.body);
      return MediaCreateResponseDto.fromJson(json);
    } catch (e) {
      print('Error creating media ${dto.localMediaId}: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncNonExistentMedias(
    List<Map<String, dynamic>> nonExistentMedias,
  ) async {
    print(
      'Starting to sync non-existent medias: ${nonExistentMedias.length} items',
    );

    for (var media in nonExistentMedias) {
      try {
        final localMediaId = media['localMediaId'];
        if (localMediaId == null) {
          print('Local Media ID is null, skipping...');
          continue;
        }

        final mediaDetails = await localDataSource.getMediaById(localMediaId);

        if (mediaDetails == null) {
          print(
            'Media details not found in local database for ID: $localMediaId',
          );
          continue;
        }

        print('Found media details---------: ${mediaDetails.toJson()}');

        final file = File(mediaDetails.filePath);
        if (!await file.exists()) {
          print('File does not exist at path: ${mediaDetails.filePath}');
          continue;
        }

        final dto = MediaUploadDto(
          fileName: path.basename(mediaDetails.filePath),
          comments: mediaDetails.comments,
          localMediaId: localMediaId,
          exerciseId: mediaDetails.exerciseId,
        );

        print('Creating media with DTO: ${dto.toFormData()}');
        final serverResponse = await createMedia(dto, mediaDetails.filePath);
        print('Successfully created media: $localMediaId');

        // Update local media sync status
        await localDataSource.updateMedia(
          mediaId: dto.localMediaId,
          exerciseId: dto.exerciseId,
          isSynced: "true",
          updatedAt: serverResponse.updatedAt,
        );

        print('Updated local media sync status for: ${dto.localMediaId}');
      } catch (e) {
        print('Failed to sync media: $e');
        continue;
      }
    }
  }

  @override
  Future<void> syncLocalNewerMedias(
    List<Map<String, dynamic>> localNewerMedias,
  ) async {
    for (var media in localNewerMedias) {
      try {
        final mediaId = media['localMediaId'];
        if (mediaId == null) {
          print('Media ID is null, skipping...');
          continue;
        }

        final mediaDetails = await localDataSource.getMediaById(mediaId);
        if (mediaDetails == null) {
          print('Media details not found in local database for ID: $mediaId');
          continue;
        }

        final serverResponse = await updateMedia(
          mediaId,
          mediaDetails.comments,
        );
        await localDataSource.updateMedia(
          mediaId: mediaId,
          exerciseId: mediaDetails.exerciseId,
          updatedAt: serverResponse.updatedAt,
          isSynced: "true",
        );
        print('Successfully updated media on server: $mediaId');
      } catch (e) {
        print('Failed to update media on server: $e');
        continue;
      }
    }
  }

  @override
  Future<void> syncServerNewerMedias(
    List<Map<String, dynamic>> serverNewerMedias,
  ) async {
    for (var media in serverNewerMedias) {
      try {
        final mediaId = media['localMediaId'];
        final comment = media['comment'];
        final updatedAt = media['updatedAt'];

        if (mediaId == null || comment == null || updatedAt == null) {
          print('Missing required fields in server media data, skipping...');
          print('Media data: $media');
          continue;
        }

        final mediaDetails = await localDataSource.getMediaById(mediaId);
        if (mediaDetails == null) {
          print('Media not found in local database for ID: $mediaId');
          continue;
        }

        await localDataSource.updateMedia(
          mediaId: mediaId,
          exerciseId: mediaDetails.exerciseId,
          comments: comment,
          updatedAt: updatedAt,
          isSynced: "true",
        );
        print('Successfully updated local media from server: $mediaId');
      } catch (e) {
        print('Failed to update local media from server: $e');
        continue;
      }
    }
  }

  @override
  Future<Map<String, dynamic>> deleteMedia(String mediaId) async {
    try {
      print('Attempting to delete media with ID: $mediaId and exerciseId:');
      print('Using token: ${_tokenService.token.value}');

      final response = await client.delete(
        Uri.parse('$backURL/Media/$mediaId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_tokenService.token.value}',
        },
      );
      print('Delete response status code: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Media  deleted successfully'};
      } else {
        final errorBody = response.body;
        print('Error response body: $errorBody');
        throw Exception('Failed to delete media: $errorBody');
      }
    } catch (e) {
      print('Remote delete error: $e');

      if (e is http.ClientException) {
        print('Network error occurred: ${e.message}');
      }

      rethrow;
    }
  }

  @override
  Future<MediaUpdateResponseDto> updateMedia(
    String mediaId,
    String comment,
  ) async {
    final token = _tokenService.token.value;
    if (token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$backURL/Media/$mediaId');
    final body = jsonEncode({'newComment': comment});


    try {
      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );


      if (response.statusCode != 200) {
        throw Exception('Failed to update exercise: ${response.body}');
      }

      final decoded = jsonDecode(response.body);
      return MediaUpdateResponseDto.fromJson(decoded);
    } catch (e) {
      print('Remote update error: $e');
      rethrow;
    }
  }
}
