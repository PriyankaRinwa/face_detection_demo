class ExportAttendanceRecordModel{
  String? empId;
  String? name;
  int? createdAt;
  double? clockIn;
  double? clockOut;

  ExportAttendanceRecordModel({this.empId, this.name, this.createdAt, this.clockIn, this.clockOut});

  factory ExportAttendanceRecordModel.fromJson(Map<dynamic, dynamic> json) => ExportAttendanceRecordModel(
    empId: json["emp_id"],
    name: json["name"],
    createdAt: json["day"],
    clockIn: json["clockin"],
    clockOut: json["clockout"],
  );

  Map<String, dynamic> toJson() => {
    "emp_id": empId,
    "name": name,
    "day": createdAt,
    "clockin": clockIn,
    "clockout": clockOut,
  };

}