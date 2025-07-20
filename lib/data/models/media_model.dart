import 'package:incubator/domain/entities/media_entity.dart';

class MediaModel extends Media {
  MediaModel({
    required super.mediaId,
    required super.exerciseId,
    required super.comments,
    required super.filePath,
    required super.isSynced,
    required super.updatedAt,
  });

  @override
  MediaModel copyWith({
    String? mediaId,
    String? exerciseId,
    String? comments,
    String? filePath,
    String? isSynced,
    String? updatedAt,
  }) {
    return MediaModel(
      mediaId: mediaId ?? this.mediaId,
      exerciseId: exerciseId ?? this.exerciseId,
      comments: comments ?? this.comments,
      filePath: filePath ?? this.filePath,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      mediaId: json["mediaId"],
      exerciseId: json["exerciseId"],
      comments: json["comments"],
      filePath: json["filePath"],
      isSynced: json["isSynced"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "mediaId": mediaId,
      "exerciseId": exerciseId,
      "comments": comments,
      "filePath": filePath,
      "isSynced": isSynced,
      "updatedAt": updatedAt,
    };
  }

  factory MediaModel.fromEntity(Media media) {
    return MediaModel(
      mediaId: media.mediaId,
      exerciseId: media.exerciseId,
      comments: media.comments,
      filePath: media.filePath,
      isSynced: media.isSynced,
      updatedAt: media.updatedAt,
    );
  }

  Media toEntity() => Media(
    mediaId: mediaId,
    exerciseId: exerciseId,
    comments: comments,
    filePath: filePath,
    isSynced: isSynced,
    updatedAt: updatedAt,
  );
}
