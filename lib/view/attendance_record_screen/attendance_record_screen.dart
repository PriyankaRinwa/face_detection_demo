import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/models/attendance_record_model.dart';
import 'package:google_ml_face_detection/provider/attendance_record_provider/attendance_record_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AttendanceRecordScreen extends StatefulWidget {
  const AttendanceRecordScreen({super.key});

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();

}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Utils.defaultText(text: "Attendance Record".tr, color: Colors.white),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: InkWell(
            onTap: ()=> Get.back(),
            child: Utils.defaultIcon(icon: Icons.chevron_left, color: Colors.white, size: 26)),
        actions: [

          InkWell(
            onTap: ()=> defaultAlertDialog(context: context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Utils.defaultIcon(icon: Icons.download_for_offline_outlined, color: Colors.white, size: 26),
            ),
          ),

        ],
      ),
      body: Consumer<AttendanceRecordProvider>(
        builder: (BuildContext context, attendanceRecordProvider, Widget? child){
          String formattedDate = DateFormat('dd/MM/yyyy').format(attendanceRecordProvider.focusDate);
          // Map the integer to the corresponding day name
          String dayName = attendanceRecordProvider.getDayName(attendanceRecordProvider.focusDate.weekday);
          return Column(
            children: [
              sizedBoxHeight_20,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Utils.defaultText(text: dayName, fontSize: 16, fontWeight: FontWeight.w600),
                    InkWell(
                      onTap: ()=> _selectDate(context),
                      child: Row(
                        children: [
                          Utils.defaultText(text: formattedDate, fontSize: 16, fontWeight: FontWeight.w600),
                          sizedBoxWidth_4,
                          Utils.defaultIcon(icon: Icons.calendar_month, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: EasyInfiniteDateTimeLine(
                  // headerProps: const EasyHeaderProps(
                  //   showSelectedDate: true,
                  //   monthPickerType: MonthPickerType.dropDown,
                  //   dateFormatter: DateFormatter.monthOnly(),
                  // ),
                  showTimelineHeader: false,
                  timeLineProps: const EasyTimeLineProps(
                    separatorPadding: 4.0
                  ),
                  dayProps: EasyDayProps(
                       height: Get.width * 0.12,
                        width: Get.width * 0.12,
                        dayStructure: DayStructure.dayNumDayStr,
                    inactiveDayStyle: DayStyle(
                         borderRadius: 10.0,
                         // decoration: BoxDecoration(
                         //   borderRadius: BorderRadius.circular(10.0),
                         //   border: Border.all(color: Colors.grey)
                         // ),
                         dayNumStyle: TextStyle(
                           fontSize: 13.0,
                           color: Colors.black.withOpacity(0.8)
                         ),
                         dayStrStyle: TextStyle(
                           fontSize: 13.0,
                             color: Colors.black.withOpacity(0.8)
                         ),
                        ),
                    activeDayStyle: const DayStyle(
                      borderRadius: 10.0,
                       dayNumStyle: TextStyle(
                       fontSize: 13.0,
                       color: Colors.white
                       ),
                      dayStrStyle: TextStyle(
                        fontSize: 13.0,
                        color: Colors.white
                      ),
                    ),
                    ),
                  controller: attendanceRecordProvider.controller,
                  firstDate: DateTime(1900, 11, 1),
                  focusDate: attendanceRecordProvider.focusDate,
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                  activeColor: Colors.blueAccent.withOpacity(0.8),
                  onDateChange: (selectedDate) => attendanceRecordProvider.callSelectedDate(selectedDate),
                ),
              ),
              sizedBoxHeight_5,
               Divider(
                color: Colors.grey.withOpacity(0.5),
                 indent: 25,
                 endIndent: 25,
              ),
              sizedBoxHeight_5,
              FutureBuilder<List<AttendanceRecordModel>>(
                future: SupaBaseService().fetchEmployeesSingleDayAttendanceRecords(selectedDate: attendanceRecordProvider.focusDate),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  print("called");
                  if (snapshot.connectionState == ConnectionState.done){

                    if(snapshot.hasData){
                      final arrSingleDayAttendanceRecord = snapshot.data!;
                        return Expanded(
                          child: arrSingleDayAttendanceRecord.isEmpty
                            ? Center(child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Utils.defaultText(text: 'No Employee attendance record found.'.tr, fontSize: 18, fontWeight: FontWeight.w500, textAlign: TextAlign.center),
                            ))
                            : ListView.separated(
                            itemCount: arrSingleDayAttendanceRecord.length,
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            // padding: EdgeInsets.zero,
                            itemBuilder: (context, index){
                              // int key = LocalDB.getUserKey(index);
                              // String documentId = documents[index].id;
                              //  String clockInOuDateTime = attendanceRecordProvider.convertTimestampIntoDate(arrSingleDayAttendanceRecord[index]["created_at"]);

                              String clockInOuDateTime = attendanceRecordProvider.showDateOnlyFormIso(arrSingleDayAttendanceRecord[index].createdAt);

                              return ListTile(
                                title: Utils.defaultText(text: arrSingleDayAttendanceRecord[index].name, fontSize: 18, fontWeight: FontWeight.w500),
                                subtitle:
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 14, color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(text: arrSingleDayAttendanceRecord[index].type==0 ? "Clock in time: " : "Clock out time: ", style: const TextStyle(fontWeight: FontWeight.w300)),
                                      TextSpan(text: clockInOuDateTime, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    color: (arrSingleDayAttendanceRecord[index].type==0) ? Colors.blueAccent.withOpacity(0.8) : Colors.red,
                                    borderRadius: BorderRadius.circular(10.0)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Utils.defaultText(text: arrSingleDayAttendanceRecord[index].type==0 ? "Clock In" : "Clock Out", fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              );
                            }, separatorBuilder: (BuildContext context, int index) {
                            return const Divider(
                              color: Colors.grey,
                              indent: 25,
                              height: 0,
                              endIndent: 25,
                            );
                          },
                          ),
                        );
                      }
                    else if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text("something went wrong"),
                      );
                     }
                    }
                  else if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(child: Center(child: CircularProgressIndicator()));
                  }
                  return const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text("something went wrong"),
                  );

                },)
            ],
          );
        }
      ),
    );
  }

  static defaultAlertDialog({required BuildContext context}){
    AttendanceRecordProvider attendanceRecordProvider = Provider.of<AttendanceRecordProvider>(context, listen: false);

    return Get.dialog(
      barrierDismissible: false,
      Dialog(
        // contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sizedBoxHeight_15,

              Utils.defaultText(text: "Export Records", fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.w600),

              sizedBoxHeight_12,

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Utils.defaultText(text: "Download attendance records in PDF format for a date range selected by you.", fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w400),
                //  Utils.defaultText(text: "Download Attendance Records in pdf Within a Date Range selected by you.", fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.w500),
              ),
              sizedBoxHeight_20,
              SfDateRangePicker(
                // onSelectionChanged: _onSelectionChanged,
                  showActionButtons: true,
                  minDate: DateTime(2024, 1, 1),
                  maxDate: DateTime.now(),
                  rangeSelectionColor: Colors.blueAccent.withOpacity(0.3),
                  startRangeSelectionColor: Colors.blueAccent.withOpacity(0.8),
                  endRangeSelectionColor: Colors.blueAccent.withOpacity(0.8),
                  // selectionTextStyle: TextStyle(
                  //   color: Colors.black, // General button text color
                  //  ),
                  headerStyle: const DateRangePickerHeaderStyle(
                    backgroundColor:Colors.blueAccent,
                    textStyle: TextStyle(
                      color: Colors.white, // Header text color
                      fontSize: 14,
                    ),
                  ),
                  onCancel: ()=> Get.back(),
                  onSubmit: (value) async {
                    print("value is--> $value");
                    attendanceRecordProvider.downloadRecord(value);
                  },
                  backgroundColor: Colors.white,
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(
                    DateTime.now().subtract(const Duration(days: 4)),
                    DateTime.now(),
                    // DateTime.now().add(const Duration(days: 3))),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

    Future<void> _selectDate(BuildContext context) async {
      AttendanceRecordProvider attendanceRecordProvider = Provider.of<AttendanceRecordProvider>(context, listen: false);
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: attendanceRecordProvider.focusDate,
        firstDate: DateTime(1900, 11, 1),
        lastDate: DateTime.now().add(const Duration(days: 7)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(  // override MaterialApp ThemeData
              colorScheme: ColorScheme.light(
                primary: Colors.blueAccent.withOpacity(0.8),  //header and selced day background color
                onPrimary: Colors.white, // titles and
                onSurface: Colors.black, // Month days , years
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // ok , cancel    buttons
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != attendanceRecordProvider.focusDate) {
          attendanceRecordProvider.updateSelectedDate = picked;
      }
  }
}
