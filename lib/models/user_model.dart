class UserModel{
  String? id;
  String? email;
  String? name;
  String? createdAt;
  String? passcode;

  UserModel({this.id, this.email, this.name, this.createdAt, this.passcode});

  factory UserModel.fromJson(Map<dynamic, dynamic> json) => UserModel(
    id: json["id"],
    email: json["email"],
    name: json["name"],
    createdAt: json["created_at"],
    passcode: json["passcode"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "name": name,
    "created_at": createdAt,
    "passcode": passcode
  };

}