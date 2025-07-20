import 'package:incubator/domain/entities/exercises_entity.dart';

class ExerciseModel extends Exercises {
  ExerciseModel({
    required super.exerciseId,
    required super.userId,
    required super.title,
    required super.startDateTime,
    required super.endDateTime,
    required super.isSynced,
    required super.updatedAt,
  });

  @override
  ExerciseModel copyWith({
    String? exerciseId,
    String? userId,
    String? title,
    String? startDateTime,
    String? endDateTime,
    String? isSynced,
    String? updatedAt,
  }) {
    return ExerciseModel(
      exerciseId: exerciseId ?? this.exerciseId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      exerciseId: json["exerciseId"],
      userId: json["userId"],
      title: json["title"],
      startDateTime: json["startDateTime"],
      endDateTime: json["endDateTime"],
      isSynced: json["isSynced"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "exerciseId": exerciseId,
      "userId": userId,
      "title": title,
      "startDateTime": startDateTime,
      "endDateTime": endDateTime,
      "isSynced": isSynced,
      "updatedAt": updatedAt,
    };
  }

  factory ExerciseModel.fromEntity(Exercises exercise) {
    return ExerciseModel(
      exerciseId: exercise.exerciseId,
      userId: exercise.userId,
      title: exercise.title,
      startDateTime: exercise.startDateTime,
      endDateTime: exercise.endDateTime,
      isSynced: exercise.isSynced,
      updatedAt: exercise.updatedAt,
    );
  }

  Exercises toEntity() => Exercises(
    exerciseId: exerciseId,
    userId: userId,
    title: title,
    startDateTime: startDateTime,
    endDateTime: endDateTime,
    isSynced: isSynced,
    updatedAt: updatedAt,
  );
}