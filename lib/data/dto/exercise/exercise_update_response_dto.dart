class ExerciseUpdateResponseDto {
  final String localExerciseId;
  final String updateDate;

  ExerciseUpdateResponseDto({
    required this.localExerciseId,
    required this.updateDate,
  });

  factory ExerciseUpdateResponseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseUpdateResponseDto(
      localExerciseId: json['localExerciseId'],
      updateDate: json['updateDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localExerciseId': localExerciseId,
      'updateDate': updateDate,
    };
  }
}