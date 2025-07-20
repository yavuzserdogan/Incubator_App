class CreateExerciseDto {
  final String title;
  final String startDateTime;
  final String endDateTime;
  final String localExerciseId;

  CreateExerciseDto({
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    required this.localExerciseId,
  });

  factory CreateExerciseDto.fromJson(Map<String, dynamic> json) {
    return CreateExerciseDto(
      title: json['title'],
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
      localExerciseId: json['localExerciseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'localExerciseId': localExerciseId,
    };
  }
}
