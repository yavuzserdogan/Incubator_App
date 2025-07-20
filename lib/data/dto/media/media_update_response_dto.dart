class MediaUpdateResponseDto {
  final String localMediaId;
  final String updatedAt;

  MediaUpdateResponseDto({
    required this.localMediaId,
    required this.updatedAt,
  });

  factory MediaUpdateResponseDto.fromJson(Map<String, dynamic> json) {
    return MediaUpdateResponseDto(
      localMediaId: json['localMediaId'],
      updatedAt: json['updateDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localMediaId': localMediaId,
      'updatedAt': updatedAt,
    };
  }
}