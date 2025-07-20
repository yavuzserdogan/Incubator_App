class Exercises {
  final String exerciseId;
  final String userId;
  final String title;
  final String startDateTime;
  final String endDateTime;
  final String isSynced;
  final String updatedAt;

  Exercises({
    required this.exerciseId,
    required this.userId,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    required this.isSynced,
    required this.updatedAt,
  });

  Exercises copyWith({
    String? exerciseId,
    String? userId,
    String? title,
    String? startDateTime,
    String? endDateTime,
    String? isSynced,
    String? updatedAt,
  }) {
    return Exercises(
      exerciseId: exerciseId ?? this.exerciseId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}