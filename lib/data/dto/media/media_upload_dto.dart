class MediaUploadDto {
  final String fileName;
  final String comments;
  final String localMediaId;
  final String exerciseId;

  MediaUploadDto({
    required this.fileName,
    required this.comments,
    required this.localMediaId,
    required this.exerciseId,
  });

  Map<String, String> toFormData() {
    return {
      'FileName': fileName,
      'Comments': comments,
      'LocalMediaId': localMediaId,
      'ExerciseId': exerciseId,
    };
  }
}