class ExerciseCreateResponseDto {
  final String localExerciseId;
  final String updateDate;

  ExerciseCreateResponseDto({
    required this.localExerciseId,
    required this.updateDate,
  });

  factory ExerciseCreateResponseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseCreateResponseDto(
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
