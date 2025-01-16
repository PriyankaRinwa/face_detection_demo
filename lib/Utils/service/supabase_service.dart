import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_face_detection/models/attendance_record_model.dart';
import 'package:google_ml_face_detection/models/employee_model.dart';
import 'package:google_ml_face_detection/models/export_attendance_record_model.dart';
import 'package:google_ml_face_detection/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseService{
  final supabase = Supabase.instance.client;


  Future<void> signInWIthOtp({required String email}) async {
      await supabase.auth.signInWithOtp(email: email);
  }

  Future<ResendResponse> resend({required String email}) async {
    return await supabase.auth.resend(
        type: OtpType.signup,
        email: email
    );
  }


  Future<AuthResponse?> verifyOtp({required String email, required String otp}) async {
    return await supabase.auth.verifyOTP(type: OtpType.email, token: otp, email: email);
  }

  Future<void> addUserDetails() async {
      final user = supabase.auth.currentUser;
      if (user != null) {
        print("New user detected. Adding user to database.");

       UserModel userModel = UserModel(
            id: user.id,
            email: user.email,
            createdAt: DateTime.now().toIso8601String(),
       );

        await Supabase.instance.client
            .from('users')
            .insert(userModel.toJson());
      }
  }

  Future<UserModel?> getSingleUSerData() async {
    final user = supabase.auth.currentUser;
      if (user != null) {
        Map<String, dynamic>? data = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if(data!=null) {
          return UserModel.fromJson(data);
        }
      }
      return null;
  }


  Future<void> updatePasscode({required String passcode}) async {
      final user = supabase.auth.currentUser;
      if(user!=null) {
         await Supabase.instance.client
            .from('users')
            .update({'passcode': passcode}) // New data to update
            .eq('id', user.id);
      }
  }

  Future<void> addEmployeeDetails(EmployeeModel employeeModel) async {
      final user = supabase.auth.currentUser;
      if (user != null) {
        print("New employee detected. Adding employee to database.");

        employeeModel.userId = user.id;
        await Supabase.instance.client
            .from('employees')
            .insert(employeeModel.toJson());
      }
  }

  Future<void> updateEmployeeDetails(EmployeeModel employeeModel, int id) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      print("New employee detected. Adding employee to database.");
      employeeModel.userId = user.id;
      await Supabase.instance.client
          .from('employees')
          .update(employeeModel.toJson())
          .eq('id', id);
    }
  }

  Future<void> deleteSingleEmployeeDetails(int id, String empId, String createdAt) async {
    final user = supabase.auth.currentUser;
    if (user != null) {

      await removeImageFromStorage(user.id, empId, createdAt);

      await Supabase.instance.client
          .from('employees')
          .delete()
          .eq('id', id);

    }
  }

  Future<List<EmployeeModel>?> fetchAllEmployees() async {
      List<Map<String, dynamic>> data =  await Supabase.instance.client
          .from('employees')
          .select("*");

      return data.map((item) => EmployeeModel.fromJson(item)).toList();
  }

  Stream<List<EmployeeModel>> fetchAllEmployeesStream() {
    print("fetching list");
    // Listen for changes in the 'users' table in real-time
    return supabase
        .from('employees') // The table you want to listen to
        .stream(primaryKey: ['id']) // Optional: To listen to changes on a specific column
        .order('created_at', ascending: true)
        .map((List<Map<String, dynamic>> event) {
      // Convert the raw data into a list of User objects
      return event.map((userMap) => EmployeeModel.fromJson(userMap)).toList();
    });
  }

  Future<EmployeeModel?> getSingleEmployeeData({required int id}) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      Map<String, dynamic>? data = await Supabase.instance.client
          .from('employees')
          .select()
          .eq('id', id)
          .maybeSingle();
      if(data!=null) {
        return EmployeeModel.fromJson(data);
      }
    }
    return null;
  }

  Future<List<EmployeeModel>?> fetchAllEmployeesExceptOwnData({required int id}) async {
    List<Map<String, dynamic>> data =  await Supabase.instance.client
        .from('employees')
        .select("*")
        .neq("id", id);

    return data.map((item) => EmployeeModel.fromJson(item)).toList();
  }

  Future<AttendanceRecordModel?> getSingleAttendancesRecord({required EmployeeModel employeeModel, required DateTime todayDate}) async {
    DateTime startOfDay = DateTime(todayDate.year, todayDate.month, todayDate.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)); // Just before midnight
    int empId = employeeModel.id!;
    Map<String, dynamic>? data =  await Supabase.instance.client
        .from('attendances')
        .select("*")
        .eq("emp_id", empId)
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', endOfDay.toIso8601String())
        .order('created_at')
        .limit(1)  // Limit to only one record
        .maybeSingle();
    if(data!=null) {
      AttendanceRecordModel attendanceRecordModel = AttendanceRecordModel.fromJson(data);
      return attendanceRecordModel;
    }
    return null;
  }


  Future<void> addEmployeeAttendanceRecord({required BuildContext context, required EmployeeModel employeeModel, VoidCallback? voidCallback, required int type}) async {
    AttendanceRecordModel newAttendanceRecordModel = AttendanceRecordModel(
       empId: employeeModel.id,
       name: employeeModel.name,
       email: employeeModel.email,
       createdAt: DateTime.now().toIso8601String(),
       type: type
    );

    await Supabase.instance.client
        .from('attendances')
        .insert(newAttendanceRecordModel.toJson());

  }

  Future<List<AttendanceRecordModel>> fetchEmployeesSingleDayAttendanceRecords({required DateTime selectedDate}) async {

    DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)); // Just before midnight

    // Convert DateTime to Firestore Timestamp
    // Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    // Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    // Listen for changes in the 'users' table in real-time
    List<Map<String, dynamic>> data = await supabase
        .from('attendances')
        .select('*')
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: true);

    return data.map((item) => AttendanceRecordModel.fromJson(item)).toList();
  }

  Future<List<ExportAttendanceRecordModel>> fetchEmployeesAttendanceData({required DateTime startDate, DateTime? endDate}) async {

    DateTime startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime endOfDay;
    if(endDate!=null) {
       endOfDay = endDate;
     //  endOfDay = endDate.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    }else {
      endOfDay = startOfDay;
   //   endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    }

    List<Map<String, dynamic>> records = await supabase.rpc("export_attendance_logs", params: {"from_date": startOfDay.toIso8601String(), "to_date": endOfDay.toIso8601String()});
    // List<Map<String, dynamic>> records = await supabase.rpc("export_attendance_logs", params: {"from_date": "2024-11-20", "to_date": "2024-11-22"});

     // List<Map<String, dynamic>> records = await supabase
     //      .from('attendances')
     //      .select('*')
     //      .gte('created_at', startOfDay.toIso8601String())
     //      .lte('created_at', endOfDay.toIso8601String())
     //
     //      .order('created_at', ascending: true);

    print(records);
    return records.map((record) => ExportAttendanceRecordModel.fromJson(record)).toList();
  }

  // Future<List<AttendanceRecordModel>> updateAttendanceRecordList({required DateTime selectedDate, required String empId}) async {
  //
  //   DateTime startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
  //   DateTime endOfDay;
  //   if(endDate!=null) {
  //     endOfDay = endDate.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
  //   }else {
  //     endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
  //   }
  //   // Listen for changes in the 'users' table in real-time
  //
  //   List<Map<String, dynamic>> data = await supabase
  //       .from('attendances')
  //       .upsert(values)
  //       .select('*');
  //
  //   return data.map((item) => AttendanceRecordModel.fromJson(item)).toList();
  // }


  Future<void> signOut() async {
    await supabase.auth.signOut();
    print("User signed out");
  }


  Future<String?> uploadImage(File image, String createdAt, String empId) async {
    // Create a reference to the storage bucket and file
    final user = supabase.auth.currentUser;
    if(user!=null){
      int timestamp = DateTime.parse(createdAt).millisecondsSinceEpoch;
      print("timestamp is--> $timestamp");
      // Timestamp timestamp = Timestamp.fromDate(DateTime.parse(createdAt));
      final fileExt = image.path.split('.').last;
      final fileName = 'users/${user.id}/employees/$empId.jpg';
   //   final fileName = 'users/${user.id}/employees/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;
      final fileBytes = await image.readAsBytes();

      // Upload the image to Supabase storage (avatars bucket)
      await supabase.storage.from('iAttendy').uploadBinary(filePath,
        fileBytes,
        // fileOptions: FileOptions(contentType: image.mimeType)
      );

      final imageUrlResponse = await supabase.storage
          .from('iAttendy')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      return imageUrlResponse;
    }
    return null;
  }

  Future<void> removeImageFromStorage(String userId, String empId, String createdAt) async {
    int timestamp = DateTime.parse(createdAt).millisecondsSinceEpoch;
    // Timestamp timestamp = Timestamp.fromDate(DateTime.parse(createdAt));
    await supabase.storage.from('iAttendy').remove(['users/$userId/employees/$empId.jpg']); // Assuming image is named by userId
  }

}