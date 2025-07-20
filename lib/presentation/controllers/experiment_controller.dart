import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/services/token_service.dart';
import 'package:incubator/domain/repositories/exercises_repositories.dart';
import 'package:incubator/presentation/components/snackbar_helper.dart';
import '../../core/services/network_service.dart';
import '../../core/utils/text_files.dart';
import '../../domain/entities/exercises_entity.dart';
import 'package:incubator/core/utils/id_generator.dart';
import 'media_controller.dart';

class ExperimentController extends GetxController {
  final ExercisesRepository _repository;
  final TokenService _tokenService;
  final NetworkService _networkService;
  final mediaController = Get.find<MediaController>();

  final isExperimentActive = false.obs;
  final currentExperiment = Rx<Exercises?>(null);
  final experimentTitle = ''.obs;
  final experiments = <Exercises>[].obs;
  final syncedCount = 0.obs;
  final unSyncedCount = 0.obs;
  final isSyncing = false.obs;

  ExperimentController(
    this._repository,
    this._tokenService,
    this._networkService,
  );

  @override
  void onInit() {
    super.onInit();
    fetchLocalExperiments();
  }

  // LOAD Exercise
  Future<void> fetchLocalExperiments() async {
    try {
      final currentUserId = _tokenService.currentUserId;
      if (currentUserId.isEmpty) {
        throw Exception("User ID not found in token");
      }
      final fetchedExperiments = await _repository.getExercise(currentUserId);

      // if (fetchedExperiments.isEmpty) {
      // } else {
      //   for (var exp in fetchedExperiments) {}
      // }

      experiments.value =
          fetchedExperiments
              .where((exp) => exp.userId == currentUserId)
              .toList();

      _updateSyncCounts();
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.downloadExerciseError);
    }
  }

  //GET Exercise
  Future<Exercises?> getExerciseById(String exerciseId) async {
    try {
      final currentUserId = _tokenService.currentUserId;
      if (currentUserId.isEmpty) {
        throw Exception("User ID not found in token");
      }

      final exercise = await _repository.getExerciseById(exerciseId);

      if (exercise != null && exercise.userId != currentUserId) {
        print('Access denied: Exercise belongs to different user');
        return null;
      }

      return exercise;
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.getExerciseError);
      return null;
    }
  }

  //CREATE Exercise
  void startExperiment({
    required String title,
    required String startTime,
  }) async {
    try {
      final currentUserId = _tokenService.currentUserId;
      if (currentUserId.isEmpty) {
        throw Exception("User ID not found in token");
      }

      if (_tokenService.currentUserId.isEmpty) {
        throw Exception("User ID not found in token");
      }

      final experimentId = IdGenerator.generateTimeBasedId();

      final startTime = DateTime.now().toUtc().toIso8601String();

      final experiment = Exercises(
        exerciseId: experimentId,
        userId: currentUserId,
        title: title,
        startDateTime: startTime,
        endDateTime: "",
        isSynced: "false",
        updatedAt: startTime,
      );

      await _repository.createExercise(experiment, currentUserId);

      final mediaController = Get.find<MediaController>();
      mediaController.setCurrentExerciseId(experimentId);

      isExperimentActive.value = true;

      currentExperiment.value = experiment;

      await fetchLocalExperiments();

      SnackBarHelper.showInfo(message: TextFiles.exercisesStart);
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.exerciseStartError);
    }
  }

  Future<void> endExperiment() async {
    try {
      if (currentExperiment.value != null) {
        final endTime = DateTime.now().toUtc().toIso8601String();

        try {
          await _repository.updateExercise(
            exerciseId: currentExperiment.value!.exerciseId,
            userId: _tokenService.currentUserId,
            endDateTime: endTime,
            updatedAt: endTime,
            isSynced: "false",
          );
        } catch (updateError) {
          rethrow;
        }

        try {
          currentExperiment.value = currentExperiment.value!.copyWith(
            endDateTime: endTime,
            updatedAt: endTime,
            isSynced: "false",
          );
        } catch (copyError) {
          rethrow;
        }

        isExperimentActive.value = false;
        currentExperiment.value = null;

        await fetchLocalExperiments();
        SnackBarHelper.showInfo(message: TextFiles.exercisesEnd);
      } else {
        throw Exception("No active experiment to end");
      }
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.exercisesEndError);
    }
  }

  //UPDATE Exercise
  Future<void> editExercise(String exerciseId, String currentTitle) async {
    try {
      final TextEditingController textController = TextEditingController(
        text: currentTitle,
      );

      await Get.dialog(
        AlertDialog(
          title: Text("Deneyi Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: "Deney Adı",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("İptal")),
            TextButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  Get.back();
                  final exercise = await _repository.getExerciseById(
                    exerciseId,
                  );
                  if (exercise != null) {
                    await _repository.updateExercise(
                      exerciseId: exerciseId,
                      userId: _tokenService.currentUserId,
                      title: textController.text,
                      updatedAt: DateTime.now().toUtc().toIso8601String(),
                      isSynced: "false",
                    );
                    await fetchLocalExperiments();
                    SnackBarHelper.showError(
                      message: TextFiles.exercisesUpdated,
                    );
                  }
                }
              },
              child: Text("Kaydet"),
            ),
          ],
        ),
      );
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.exercisesUpdatedError);
    }
  }

  //UPDATE SYNC count
  void _updateSyncCounts() {
    syncedCount.value =
        experiments.where((exp) => exp.isSynced == "true").length;
    unSyncedCount.value =
        experiments.where((exp) => exp.isSynced == "false").length;
    print(
      'Sync Counts Updated - Synced: ${syncedCount.value}, Unsynced: ${unSyncedCount.value}',
    );
  }

  //DELETE Exercise
  Future<void> deleteExercise(String exerciseId) async {
    try {
      if (!await _networkService.checkInternetConnection()) {
        SnackBarHelper.showError(message: TextFiles.networkError);
        return;
      }

      if (_tokenService.token.value.isEmpty) {
        SnackBarHelper.showError(message: TextFiles.login);
        return;
      }

      final mediaList = await mediaController.getMediaByExerciseId(exerciseId);

      for (var media in mediaList) {
        await mediaController.deleteMedia(media.mediaId);
      }
      await _repository.deleteExercise(exerciseId, _tokenService.currentUserId);
      await fetchLocalExperiments();
      SnackBarHelper.showError(message: TextFiles.exerciseDelete);
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.exerciseDeleteError);
    }
  }

  //SYNC Exercise
  Future<void> syncExercises() async {
    if (isSyncing.value) return;

    try {
      isSyncing.value = true;

      if (!await _networkService.checkInternetConnection()) {
        SnackBarHelper.showError(message: TextFiles.networkError);
        return;
      }

      final syncedExercises = await _repository.getExerciseBySynced(
        _tokenService.currentUserId,
        // false,
      );

      final response = await _repository.syncExercisesToServer(syncedExercises);
      await fetchLocalExperiments();

      SnackBarHelper.showInfo(message: TextFiles.exerciseSync);
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.exerciseSyncError);
    } finally {
      isSyncing.value = false;
    }
  }
}
