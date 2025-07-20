import "package:incubator/domain/entities/user_entity.dart";

class UserModel extends User {
  UserModel({
    required super.userId,
    required super.name,
    required super.surname,
    required super.email,
    required super.password,
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? surname,
    String? email,
    String? password,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["userId"],
      name: json["name"],
      surname:json["surname"],
      email: json["email"],
      password: json["password"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "surname": surname,
      "email": email,
      "password": password,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      name: user.name,
      surname: user.surname,
      email: user.email,
      password: user.password,
    );
  }

  User toEntity()=> User(
        userId: userId,
        name: name,
        surname: surname,
        email: email,
        password: password,
      );
}
