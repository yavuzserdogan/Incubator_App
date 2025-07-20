import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:incubator/core/constants/api_constant.dart';
import 'package:incubator/core/services/token_service.dart';
import 'package:incubator/data/dto/exercise/exercise_update_response_dto.dart';
import '../../dto/exercise/exercise_create_dto.dart';
import '../../dto/exercise/exercise_create_response_dto.dart';
import '../local/exercises_local_data_source.dart';

class SyncResponse {
  final List<Map<String, dynamic>> nonExistentExercises;
  final List<Map<String, dynamic>> serverNewerExercises;
  final List<Map<String, dynamic>> localNewerExercises;
  final List<Map<String, dynamic>> nonExistentLocalExercises;

  SyncResponse({
    required this.nonExistentExercises,
    required this.serverNewerExercises,
    required this.localNewerExercises,
    required this.nonExistentLocalExercises,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    return SyncResponse(
      nonExistentExercises: List<Map<String, dynamic>>.from(
        json['nonExistentExercises'] ?? [],
      ),
      serverNewerExercises: List<Map<String, dynamic>>.from(
        json['serverNewerExercises'] ?? [],
      ),
      localNewerExercises: List<Map<String, dynamic>>.from(
        json['localNewerExercises'] ?? [],
      ),
      nonExistentLocalExercises: List<Map<String, dynamic>>.from(
        json['nonExistentLocalExercises'] ?? [],
      ),
    );
  }
}

abstract class ExercisesRemoteDataSource {
  Future<SyncResponse> syncExercises(List<Map<String, dynamic>> exercises);

  Future<ExerciseCreateResponseDto> createExercise(CreateExerciseDto dto);

  Future<void> syncNonExistentExercises(
    List<Map<String, dynamic>> nonExistentExercises,
  );

  Future<Map<String, dynamic>> deleteExercise(String id);

  Future<ExerciseUpdateResponseDto> updateExercise(
    String exerciseId,
    String title,
  );

  Future<void> syncLocalNewerExercises(
    List<Map<String, dynamic>> localNewerExercises,
  );

  Future<void> syncServerNewerExercises(
    List<Map<String, dynamic>> serverNewerExercises,
  );
}

class ExercisesRemoteDataSourceImpl implements ExercisesRemoteDataSource {
  final http.Client client;
  final TokenService _tokenService = Get.find<TokenService>();
  final ExercisesLocalDataSource localDataSource =
      Get.find<ExercisesLocalDataSource>();

  final backURL = ApiConstant.baseURL;

  ExercisesRemoteDataSourceImpl({required this.client});

  @override
  Future<SyncResponse> syncExercises(
    List<Map<String, dynamic>> exercises,
  ) async {
    final token = _tokenService.token.value;
    if (token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await client.post(
      Uri.parse('$backURL/Exercise/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(exercises),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sync exercises');
    }

    final responseData = jsonDecode(response.body);

    final syncResponse = SyncResponse.fromJson(responseData);

    return syncResponse;
  }

  @override
  Future<ExerciseCreateResponseDto> createExercise(
    CreateExerciseDto dto,
  ) async {
    final token = _tokenService.token.value;
    if (token.isEmpty) throw Exception('No authentication token found');

    final response = await client.post(
      Uri.parse('$backURL/Exercise'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create exercise');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return ExerciseCreateResponseDto.fromJson(json);
  }

  @override
  Future<void> syncNonExistentExercises(
    List<Map<String, dynamic>> nonExistentExercises,
  ) async {
    for (var exercise in nonExistentExercises) {
      try {
        final exerciseId = exercise['exerciseId'];
        if (exerciseId == null) {
          print('Exercise ID is null, skipping...');
          continue;
        }

        final exerciseDetails = await localDataSource.getExerciseById(
          exerciseId,
        );
        if (exerciseDetails == null) {
          print(
            'Exercise details not found in local database for ID: $exerciseId',
          );
          continue;
        }

        final dto = CreateExerciseDto(
          title: exerciseDetails.title,
          startDateTime: exerciseDetails.startDateTime,
          endDateTime: exerciseDetails.endDateTime,
          localExerciseId: exerciseId,
        );

        final serverResponse = await createExercise(dto);

        await localDataSource.updateExercise(
          exerciseId: exerciseId,
          userId: exerciseDetails.userId,
          updatedAt: serverResponse.updateDate,
          isSynced: "true",
        );
      } catch (e) {
        print('Failed to sync exercise: $e');
        continue;
      }
    }
  }

  @override
  Future<void> syncLocalNewerExercises(
    List<Map<String, dynamic>> localNewerExercises,
  ) async {
    for (var exercise in localNewerExercises) {
      try {
        final exerciseId = exercise['exerciseId'];
        if (exerciseId == null) {
          print('Exercise ID is null, skipping...');
          continue;
        }

        final exerciseDetails = await localDataSource.getExerciseById(
          exerciseId,
        );
        if (exerciseDetails == null) {
          print(
            'Exercise details not found in local database for ID: $exerciseId',
          );
          continue;
        }

        final serverResponse = await updateExercise(
          exerciseId,
          exerciseDetails.title,
        );
        await localDataSource.updateExercise(
          exerciseId: exerciseId,
          userId: exerciseDetails.userId,
          updatedAt: serverResponse.updateDate,
          isSynced: "true",
        );
      } catch (e) {
        continue;
      }
    }
  }

  @override
  Future<void> syncServerNewerExercises(
    List<Map<String, dynamic>> serverNewerExercises,
  ) async {
    for (var exercise in serverNewerExercises) {
      try {
        final exerciseId = exercise['exerciseId'];
        final title = exercise['title'];
        final updatedAt = exercise['updatedAt'];

        if (exerciseId == null || title == null || updatedAt == null) {
          print('Missing required fields in server exercise data, skipping...');
          continue;
        }

        final exerciseDetails = await localDataSource.getExerciseById(
          exerciseId,
        );
        if (exerciseDetails == null) {
          print('Exercise not found in local database for ID: $exerciseId');
          continue;
        }

        await localDataSource.updateExercise(
          exerciseId: exerciseId,
          userId: exerciseDetails.userId,
          title: title,
          updatedAt: updatedAt,
          isSynced: "true",
        );
        print('Successfully updated local exercise from server: $exerciseId');
      } catch (e) {
        print('Failed to update local exercise from server: $e');
        continue;
      }
    }
  }

  @override
  Future<Map<String, dynamic>> deleteExercise(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$backURL/Exercise/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_tokenService.token.value}',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Exercise deleted successfully'};
      } else {
        throw Exception('Failed to delete exercise: ${response.body}');
      }
    } catch (e) {
      print('Remote delete error: $e');
      rethrow;
    }
  }

  @override
  Future<ExerciseUpdateResponseDto> updateExercise(
    String exerciseId,
    String title,
  ) async {
    final token = _tokenService.token.value;
    if (token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$backURL/Exercise/$exerciseId');
    final body = jsonEncode({'newTitle': title});

    print('[PUT] $url');
    print('Request Body: $body');

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
      return ExerciseUpdateResponseDto.fromJson(decoded);
    } catch (e) {
      print('Remote update error: $e');
      rethrow;
    }
  }
}
