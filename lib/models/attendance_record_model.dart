class AttendanceRecordModel{
  String? id;
  int? empId;
  String? name;
  String? email;
  String? createdAt;
  int? type;

  AttendanceRecordModel({this.id, this.empId, this.name, this.email, this.createdAt, this.type});

  factory AttendanceRecordModel.fromJson(Map<dynamic, dynamic> json) => AttendanceRecordModel(
    id: json["id"],
    empId: json["emp_id"],
    name: json["name"],
    email: json["email"],
    createdAt: json["created_at"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    // "id": id,
    "emp_id": empId,
    "name": name,
    "email": email,
    "created_at": createdAt,
    "type": type
  };

}