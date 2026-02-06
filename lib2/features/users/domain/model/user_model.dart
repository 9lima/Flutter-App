class UserModel {
  final int id;
  final String firstName;
  final String email;

  UserModel({required this.id, required this.firstName, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'firstName': firstName, 'email': email};
  }
}
