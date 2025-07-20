class MediaCreateResponseDto {
  final String localMediaId;
  final String updatedAt;

  MediaCreateResponseDto({
    required this.localMediaId,
    required this.updatedAt,
  });

  factory MediaCreateResponseDto.fromJson(Map<String, dynamic> json) {
    return MediaCreateResponseDto(
      localMediaId: json['localMediaId'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localMediaId': localMediaId,
      'updatedAt': updatedAt,
    };
  }
}