class Media {
  final String mediaId;
  final String exerciseId;
  final String comments;
  final String filePath;
  final String isSynced;
  final String updatedAt;

  Media({
    required this.mediaId,
    required this.exerciseId,
    required this.comments,
    required this.filePath,
    required this.isSynced,
    required this.updatedAt,
  });

  Media copyWith({
    String? mediaId,
    String? exerciseId,
    String? comments,
    String? filePath,
    String? isSynced,
    String? updatedAt,
  }) {
    return Media(
      mediaId: mediaId ?? this.mediaId,
      exerciseId: exerciseId ?? this.exerciseId,
      comments: comments ?? this.comments,
      filePath: filePath ?? this.filePath,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
