// import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel{
  int? id;
  String? userId;
  String? empId;
  String? name;
  String? email;
  List? imageData;
  String? imageUrl;
  String? createdAt;

  EmployeeModel({this.id, this.userId, this.empId, this.name, this.email, this.imageData, this.imageUrl, this.createdAt});

  factory EmployeeModel.fromJson(Map<dynamic, dynamic> json) => EmployeeModel(
    id: json["id"],
    userId: json["user_id"],
    empId: json["emp_id"],
    name: json["name"],
    email: json["email"],
    imageData: json["image_data"],
    imageUrl: json["image_url"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    // "id": id,  /// It will auto generate by Postgrest
    "user_id": userId,
    "emp_id": empId,
    "name": name,
    "email": email,
    "image_data": imageData,
    "image_url": imageUrl,
    "created_at": createdAt,
  };

  // factory EmployeeModel.fromDocument(DocumentSnapshot doc) {
  //   return EmployeeModel(
  //     id: int.parse(doc.id),
  //     userId: doc["user_id"],
  //     empId: doc["emp_id"],
  //     name: doc["name"],
  //     email: doc["email"],
  //     imageData: doc["image_data"],
  //     imageUrl: doc["image_url"],
  //     createdAt: doc["created_at"]
  //   );
  // }
}