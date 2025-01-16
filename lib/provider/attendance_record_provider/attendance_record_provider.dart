import 'dart:async';
import 'dart:io';
// import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/service/notification_service.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/models/export_attendance_record_model.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AttendanceRecordProvider extends ChangeNotifier{
  final StreamController<DateTime> dateController = StreamController<DateTime>.broadcast();
  final EasyInfiniteDateTimelineController controller = EasyInfiniteDateTimelineController();
  DateTime _focusDate = DateTime.now();

  DateTime get focusDate => _focusDate;

  set updateSelectedDate(DateTime pickedDate){
    _focusDate = pickedDate;
    controller.animateToDate(pickedDate, duration: const Duration(milliseconds: 500));
    notifyListeners();
  }

  callSelectedDate(DateTime selectedDate){
    _focusDate = selectedDate;
    notifyListeners();

    SupaBaseService().fetchEmployeesSingleDayAttendanceRecords(selectedDate: _focusDate);
  }

  String showDateOnlyFormIso(String selectedDate){
    // DateTime dateTime = timestamp.toDate();

    // Format the date (e.g., "yyyy-MM-dd") to match your database format
      DateTime dateTime = DateTime.parse(selectedDate);
      return DateFormat('h:mm a').format(dateTime);
   // return dateTime.toIso8601String().split('T')[0];

  }

  // Future<void> generatePDF(List<AttendanceRecordModel> records) async {
  //   final pdf = pw.Document();
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             pw.Text('Attendance Data Report'.tr, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 20),
  //             pw.Table.fromTextArray(
  //               context: context,
  //               data: [
  //                 ['Emp_ID', 'ID', 'ID' 'Name', 'Clock in/out time'],  // Header row
  //                 ...records.map((record) => [record.empId, record.id, record.name, (record.type == 0) ? "Clock in ${record.createdAt}" : "Clock out ${record.createdAt}"])
  //               ],
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // Get the app's document directory to save the PDF
  //   final output = await getTemporaryDirectory();
  //   final file = File("${output.path}/report.pdf");
  //
  //   // Write the PDF to the file
  //   await file.writeAsBytes(await pdf.save());
  //
  //   // Optionally, you can use file_saver to open/save the file
  //   FileSaver.instance.saveFile(name: "attendance_report.pdf",file: file, bytes: await pdf.save(), ext: "pdf");
  // }

  Future<void> downloadRecord(Object? value) async {
    if (value is PickerDateRange) {
      final DateTime rangeStartDate = value.startDate!;
      DateTime? rangeEndDate;
      if(value.endDate!=null) {
        rangeEndDate = value.endDate!;
      }
      // if (rangeEndDate.isAfter(DateTime.now())) {
      //   // Optionally show a message or revert the selection
      //  Utils.defaultFlutterToast(text: "You cannot select a future date.".tr);
      //   return; // Revert to the previous date selection
      // }

      PermissionStatus permissionStatus = await requestStoragePermission();
      print("permission status is--> $permissionStatus");
      if(permissionStatus.isDenied){
       return;
      }else if(permissionStatus.isPermanentlyDenied){
        await openAppSettings();
        return;
      }

      /// This is for dismiss date range popup
      Get.back();

      try {
        Utils.customLoadingWidget();
        List<ExportAttendanceRecordModel> employeeAttendanceRecordData = await SupaBaseService().fetchEmployeesAttendanceData(startDate: rangeStartDate, endDate: rangeEndDate);
        if (employeeAttendanceRecordData.isNotEmpty) {
          await exportDataToExcel(employeeAttendanceRecordData);
          Get.back();
          Utils.defaultFlutterToast(text: "Attendances record downloaded successfully.");
        } else {
          Get.back();
          Utils.defaultFlutterToast(text: "No records found between those days");
        }
      } catch(e){
        print("error--> $e");
        Get.back();
        if(e is Exception){
          Utils.defaultFlutterToast(text: e.toString());
        }
      }
    }
  }

  Future<PermissionStatus> requestStoragePermission() async {
    if (GetPlatform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        /// use [Permissions.storage.status]
        return await Permission.storage.request();
      }  else {
        return await Permission.manageExternalStorage.request();
       // return await Permission.photos.request();
      }
    }
    else {
      return await Permission.manageExternalStorage.request();
     // return await Permission.photos.request();
    }
  }


  Future<void> exportDataToExcel(List<ExportAttendanceRecordModel> records) async {
   //try{
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    CellStyle? cellStyleHeader1 = CellStyle(
      backgroundColorHex: ExcelColor.deepOrange200,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center
    );
    CellStyle? cellStyleHeader2 = CellStyle(
      backgroundColorHex: ExcelColor.blue,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center
    );

    print("vale is--> ${TableColumn.shift.columnName}");

    // Add headers
    if (records.isNotEmpty) {
      List<TextCellValue> rowHeader = [TextCellValue(TableColumn.srNo.columnName), TextCellValue(TableColumn.empId.columnName), TextCellValue(TableColumn.empName.columnName), TextCellValue(TableColumn.shift.columnName), TextCellValue(TableColumn.date.columnName), TextCellValue(TableColumn.punchTime1.columnName), TextCellValue(TableColumn.punchTime2.columnName)];
      sheet.appendRow(rowHeader);
      sheet.cell(CellIndex.indexByString("A1")).cellStyle = cellStyleHeader1;
      sheet.cell(CellIndex.indexByString("B1")).cellStyle = cellStyleHeader2;
      sheet.cell(CellIndex.indexByString("C1")).cellStyle = cellStyleHeader1;
      sheet.cell(CellIndex.indexByString("D1")).cellStyle = cellStyleHeader1;
      sheet.cell(CellIndex.indexByString("E1")).cellStyle = cellStyleHeader2;
      sheet.cell(CellIndex.indexByString("F1")).cellStyle = cellStyleHeader1;
      sheet.cell(CellIndex.indexByString("G1")).cellStyle = cellStyleHeader1;
    }

    int srNo = 1;
    // Add data rows
    for (var row in records) {

      // List<AttendanceExcelSheetModel> attendanceList = [];
      // AttendanceExcelSheetModel attendanceExcelSheetModel;
      //
      // if (attendanceList.isNotEmpty) {
      //   for (int i = 0; i < attendanceList.length; i++) {
      //     if (attendanceList[i].empId == row.id && timestamp.millisecondsSinceEpoch == attendanceList[i].dateTimestamp) {
      //       if (attendanceList[i].punchTime2 == null) {
      //         String? clockInTime = attendanceList[i].punchTime1;
      //          attendanceExcelSheetModel = AttendanceExcelSheetModel(
      //             srNo: srNo.toString(),
      //             empId: row.empId.toString(),
      //             empName: row.name,
      //             dateTimestamp: timestamp.millisecondsSinceEpoch,
      //             punchTime1: clockInTime,
      //             punchTime2: clockInOutTime
      //         );
      //         attendanceList.add(attendanceExcelSheetModel);
      //       }
      //       else{
      //         attendanceExcelSheetModel = AttendanceExcelSheetModel(
      //             srNo: srNo.toString(),
      //             empId: row.empId.toString(),
      //             empName: row.name,
      //             dateTimestamp: timestamp.millisecondsSinceEpoch,
      //             punchTime1: clockInOutTime,
      //             punchTime2: null
      //         );
      //         attendanceList.add(attendanceExcelSheetModel);
      //       }
      //
      //     }
      //     else{
      //        attendanceExcelSheetModel = AttendanceExcelSheetModel(
      //           srNo: srNo.toString(),
      //           empId: row.empId.toString(),
      //           empName: row.name,
      //           dateTimestamp: timestamp.millisecondsSinceEpoch,
      //           punchTime1: clockInOutTime,
      //           punchTime2: null
      //       );
      //       attendanceList.add(attendanceExcelSheetModel);
      //     }
      //   }
      // } else {
      //      attendanceExcelSheetModel = AttendanceExcelSheetModel(
      //        srNo: srNo.toString(),
      //        empId: row.empId.toString(),
      //        empName: row.name,
      //        dateTimestamp: timestamp.millisecondsSinceEpoch,
      //        punchTime1: clockInOutTime,
      //        punchTime2: null
      //   );
      //   attendanceList.add(attendanceExcelSheetModel);
      // }

      // DateTime dateTime = DateTime.parse(row.createdAt.toString());
      // String clockInOutDate = DateFormat('dd-MMM-yyyy').format(dateTime);
      // print("clock in/out date--> $clockInOutDate");

      // String clockInOutTime = DateFormat('hh-mm a').format(dateTime);
      // print("clock in/out time--> $clockInOutTime");
      // String type = row.type==0 ? "Clock In" : "Clock Out";

      CellStyle? cellStyle1 = CellStyle(
          horizontalAlign: HorizontalAlign.Left,
          verticalAlign: VerticalAlign.Center
      );
      CellStyle? cellStyle2 = CellStyle(
          horizontalAlign: HorizontalAlign.Right,
          verticalAlign: VerticalAlign.Center,
      );
      CellStyle? cellStyleDate = CellStyle(
          horizontalAlign: HorizontalAlign.Right,
          verticalAlign: VerticalAlign.Center,
          numberFormat: NumFormat.standard_15
      );
      CellStyle? cellStyleTime = CellStyle(
          horizontalAlign: HorizontalAlign.Right,
          verticalAlign: VerticalAlign.Center,
          numberFormat: NumFormat.standard_18
      );


      DateTime clockInOutDateTime = DateTime.fromMillisecondsSinceEpoch((row.createdAt??0) * 1000, isUtc: true);
      String clockInOutDate = DateFormat('dd-MMM-yyyy').format(clockInOutDateTime);
      print("clock in/out date--> $clockInOutDate");

      DateTime? clockInDateTime;
      if(row.clockIn!=null) {
        clockInDateTime = DateTime.fromMillisecondsSinceEpoch(row.clockIn!.toInt() * 1000, isUtc: true);
      }
      // String clockInTime = (clockInDateTime!=null) ? DateFormat('hh:mm a').format(clockInDateTime) : '';
      //String clockInTime = (clockInDateTime!=null) ? DateFormat('hh:mm:ss a').format(clockInDateTime) : '';
       print("clock in time--> $clockInDateTime");

       DateTime? clockOutDateTime;
      if(row.clockOut!=null) {
        clockOutDateTime = DateTime.fromMillisecondsSinceEpoch(row.clockOut!.toInt() * 1000, isUtc: true);
       }
      // String clockOutTime = (clockOutDateTime!=null) ? DateFormat('hh:mm a').format(clockOutDateTime) : '';
      // String clockOutTime = (clockOutDateTime!=null) ? DateFormat('hh:mm:ss a').format(clockOutDateTime) : '';
       print("clock in time--> $clockOutDateTime");

       String shift = "General";

      List<CellValue> rowValues = [TextCellValue(srNo.toString()), TextCellValue(row.empId.toString()), TextCellValue(row.name.toString()), TextCellValue(shift), DateCellValue.fromDateTime(clockInOutDateTime), clockInDateTime != null ? TimeCellValue.fromTimeOfDateTime(clockInDateTime) : TextCellValue(""), clockOutDateTime!=null ? TimeCellValue.fromTimeOfDateTime(clockOutDateTime) : TextCellValue("")];
      // List<TextCellValue> rowValues = [TextCellValue(srNo.toString()), TextCellValue(row.empId.toString()), TextCellValue(row.name.toString()), TextCellValue(shift), TextCellValue(clockInOutDate), TextCellValue(clockInTime), TextCellValue(clockOutTime)];
      sheet.appendRow(rowValues);
      srNo++;
      sheet.cell(CellIndex.indexByString("A$srNo")).cellStyle = cellStyle2;
      sheet.cell(CellIndex.indexByString("B$srNo")).cellStyle = cellStyle1;
      sheet.cell(CellIndex.indexByString("C$srNo")).cellStyle = cellStyle1;
      sheet.cell(CellIndex.indexByString("D$srNo")).cellStyle = cellStyle1;
      sheet.cell(CellIndex.indexByString("E$srNo")).cellStyle = cellStyleDate;
      sheet.cell(CellIndex.indexByString("F$srNo")).cellStyle = cellStyleTime;
      sheet.cell(CellIndex.indexByString("G$srNo")).cellStyle = cellStyleTime;
    }

    // Get the storage path

    Directory? directory;

    // Get the external storage directory on Android
    if(GetPlatform.isAndroid) {
      directory =  await getExternalStorageDirectory();
    }else if(GetPlatform.isIOS){
      directory = await getApplicationDocumentsDirectory();
    }

    // downloadsDir = await getDownloadsDirectory();

    if(directory!= null && await directory.exists()) {
      print("exists");
      String path = directory.absolute.path;
      print("directory path--> $path");

      if(GetPlatform.isAndroid) {
        // Find the index of "Android" in the path
        int index = path.indexOf('0');
        print("index--> $index");

        // Extract the path up to the "Android" folder
        path = "${path.substring(0, index + 1)}/Download";
        print("newPath--> $path");
      }

      final file = File('$path/attendance_record_${DateTime.now().millisecondsSinceEpoch}.xlsx');

      // Write CSV data to the file
      File downloadedRecordFile = await file.writeAsBytes(excel.encode()!);

      print('File saved to: $path');

      // Show a notification with the path to the downloaded file
      NotificationService.showDownloadCompleteNotification('Download Complete', 'Your data download is complete!', downloadedRecordFile.path);

    }else{
      print("path not available");
    }
  //}
  // catch (e) {
  //   print('Error: $e');
  // }

  }

  // Future<void> downloadCsv(List<AttendanceRecordModel> records) async {
  //   try {
  //
  //     // AttendanceRecordModel attendanceRecordModel = AttendanceRecordModel();
  //     // Convert the data to CSV format
  //     List<List<dynamic>> rows = [];
  //     // Adding headers
  //     rows.add(["Employee Id", "Employee Name", "Employee Email", "Clock In/Out Time", "Type"]);
  //     //  rows.add(attendanceRecordModel.toJson().keys.toList());
  //     // Adding data rows
  //     for (var row in records) {
  //
  //       DateTime dateTime = DateTime.parse(row.createdAt.toString());
  //       String clockInOutDateTime = DateFormat('yyyy-MM-dd').format(dateTime);
  //      // String clockInOutDateTime = DateFormat('yyyy-MM-dd h:mm:ss').format(dateTime);
  //       print("clock in/out time--> $clockInOutDateTime");
  //       String type = row.type==0 ? "Clock In" : "Clock Out";

  //        rows.add([row.empId, row.name, row.email, clockInOutDateTime, type]);
  //       // rows.add(row.toJson().values.toList());
  //     }
  //
  //     String csvData = const ListToCsvConverter().convert(rows);
  //
  //     Directory? directory;
  //
  //    // Get the external storage directory on Android
  //     if(GetPlatform.isAndroid) {
  //       directory =  await getExternalStorageDirectory();
  //     }else if(GetPlatform.isIOS){
  //       directory = await getApplicationDocumentsDirectory();
  //     }
  //
  //     //downloadsDir = await getDownloadsDirectory();
  //
  //     if(directory!= null && await directory.exists()) {
  //       print("exists");
  //       String path = directory.absolute.path;
  //       print("directory path--> $path");
  //
  //       if(GetPlatform.isAndroid) {
  //         // Find the index of "Android" in the path
  //         int index = path.indexOf('0');
  //         print("index--> $index");
  //
  //         // Extract the path up to the "Android" folder
  //         path = "${path.substring(0, index + 1)}/Download";
  //         print("newPath--> $path");
  //       }
  //
  //       final file = File('$path/attendance_record_${DateTime.now().millisecondsSinceEpoch}.csv');
  //
  //       // Write CSV data to the file
  //       await file.writeAsString(csvData);
  //
  //       print('CSV file saved at ${file.path}');
  //     }else{
  //       print("path not available");
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  // Function to map weekday number to day name

  String getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

}

// Enum for column names
enum TableColumn {
  srNo,
  empId,
  empName,
  date,
  punchTime1,
  punchTime2,
  shift
}

// Extension to get the string value
extension TableColumnExtension on TableColumn {
  String get columnName {
    switch (this) {
      case TableColumn.srNo:
        return 'Sr No';
      case TableColumn.empId:
        return 'Emp ID';
      case TableColumn.empName:
        return 'Emp Name';
      case TableColumn.date:
        return 'Date';
      case TableColumn.punchTime1:
        return 'Punch Time 1';
      case TableColumn.punchTime2:
        return 'Punch Time 2';
      case TableColumn.shift:
        return 'Shift';
    }
  }
}


class AttendanceExcelSheetModel{
  String? srNo;
  String? empId;
  String? empName;
  int? dateTimestamp;
  String? punchTime1;
  String? punchTime2;
  String? shift;

  AttendanceExcelSheetModel({this.srNo, this.empId, this.empName, this.dateTimestamp, this.punchTime1, this.punchTime2, this.shift});

}
