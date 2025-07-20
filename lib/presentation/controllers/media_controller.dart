import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/domain/entities/media_entity.dart';
import 'package:incubator/domain/repositories/media_repositories.dart';
import 'package:incubator/presentation/components/snackbar_helper.dart';
import '../../core/services/network_service.dart';
import '../../core/services/token_service.dart';
import 'package:incubator/core/utils/id_generator.dart';

import '../../core/utils/text_files.dart';

class MediaController extends GetxController {
  final MediaRepository _mediaRepository;
  final NetworkService _networkService;
  final TokenService _tokenService;
  final RxList<Media> mediaList = <Media>[].obs;
  final isSyncing = false.obs;

  RxString imagePath = ''.obs;
  RxString comments = ''.obs;
  RxBool isLoading = false.obs;
  RxString currentExerciseId = ''.obs;

  MediaController(
    this._mediaRepository,
    this._tokenService,
    this._networkService,
  );

  void setCurrentExerciseId(String exerciseId) {
    currentExerciseId.value = exerciseId;
  }

  void setImagePath(String path) {
    imagePath.value = path;
  }

  void setComments(String text) {
    comments.value = text;
  }

  void clearMedia() {
    imagePath.value = '';
    comments.value = '';
  }

  //LOAD Media
  Future<void> fetchLocalMedias() async {
    try {
      if (_tokenService.currentUserId.isEmpty) {
        throw Exception("User ID not found in token");
      }
      final medias = await _mediaRepository.getMediaByExerciseId(
        currentExerciseId.value,
      );
      mediaList.value = medias;
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.mediaUploadError);
    }
  }

  //GET Media
  Future<List<Media>> getMediaByExerciseId(String exerciseId) async {
    try {
      return await _mediaRepository.getMediaByExerciseId(exerciseId);
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.mediaIfoError);
      return [];
    }
  }

  //CREATE Media
  Future<void> saveMedia() async {
    if (imagePath.value.isEmpty) {
      SnackBarHelper.showInfo(message: TextFiles.takePhoto);
      return;
    }

    if (currentExerciseId.value.isEmpty) {
      SnackBarHelper.showError(message: TextFiles.exercisesEmpty);
      return;
    }

    try {
      isLoading.value = true;

      final mediaId = IdGenerator.generateTimeBasedId();

      final media = Media(
        mediaId: mediaId,
        exerciseId: currentExerciseId.value,
        comments: comments.value,
        filePath: imagePath.value,
        isSynced: "false",
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _mediaRepository.createMedia(media, currentExerciseId.value);

      SnackBarHelper.showInfo(message: TextFiles.mediaSave);

      clearMedia();
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.mediaSaveError);
    } finally {
      isLoading.value = false;
    }
  }

  //UPDATE Media
  Future<void> editMedia(String mediaId, String currentComment) async {
    try {
      final TextEditingController textController = TextEditingController(
        text: currentComment,
      );

      await Get.dialog(
        AlertDialog(
          title: Text("Yorumu Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: "Yorum",
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
                  final media = await _mediaRepository.getMediaById(
                    mediaId,
                    //currentExerciseId.value,
                  );
                  if (media != null) {
                    await _mediaRepository.updateMedia(
                      mediaId: mediaId,
                      exerciseId: currentExerciseId.value,
                      comments: textController.text,
                      updatedAt: DateTime.now().toUtc().toIso8601String(),
                      isSynced: "false",
                    );
                    await fetchLocalMedias();
                    SnackBarHelper.showInfo(message: TextFiles.mediaUpdate);
                  }
                }
              },
              child: Text("Kaydet"),
            ),
          ],
        ),
      );
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.mediaUpdateError);
    }
  }

  //DELETE Media
  Future<void> deleteMedia(String mediaId) async {
    try {
      if (!await _networkService.checkInternetConnection()) {
        SnackBarHelper.showError(message: TextFiles.networkError);
        return;
      }

      if (_tokenService.token.value.isEmpty) {
        SnackBarHelper.showInfo(message: TextFiles.login);
        return;
      }

      await _mediaRepository.deleteMedia(mediaId, currentExerciseId.value);
      await fetchLocalMedias();
      SnackBarHelper.showInfo(message: TextFiles.mediaDelete);
    } catch (e) {
      if (e.toString().contains('UNAUTHORIZED_ACCESS')) {
        SnackBarHelper.showError(message: TextFiles.login);
      } else if (e.toString().contains('Failed to delete media')) {
        SnackBarHelper.showError(message: TextFiles.mediaDeleteError);
      } else {
        SnackBarHelper.showError(message: TextFiles.unknownError);
      }
    }
  }

  //SYNC Media
  Future<void> syncMedia() async {
    if (isSyncing.value) return;

    try {
      isSyncing.value = true;

      if (!await _networkService.checkInternetConnection()) {
        SnackBarHelper.showError(message: TextFiles.networkError);
        return;
      }

      await fetchLocalMedias();
    } catch (e) {
      SnackBarHelper.showError(message: TextFiles.exerciseSyncError);
    } finally {
      isSyncing.value = false;
    }
  }
}
