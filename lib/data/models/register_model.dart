class RegisterModel {
  final String name;
  final String surname;
  final String email;
  final String password;

  RegisterModel({
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'surname': surname,
    'email': email,
    'password': password,
  };
}