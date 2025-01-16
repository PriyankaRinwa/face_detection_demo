import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/provider/dashboard_provider/dashboard_provider.dart';
import 'package:provider/provider.dart';

import '../../models/employee_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver{
 @override
  void initState() {
   // Provider.of<DashboardProvider>(context, listen: false).getEmployeeList();
   // Future.microtask(() =>
   //     context.read<DashboardProvider>().getEmployeeList()
   // );
   //  _faceDetectorService.initialize();
   WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("AppLifecycleState is: $state");

    /// need to update ui because after unpin app It's going into inactive after hidden after pause state and coming back its in resumed state so need to update for employee data fetching
    if (state == AppLifecycleState.resumed) {
      Provider.of<DashboardProvider>(context, listen: false).updateUi();
    }
  }

  @override
  Widget build(BuildContext context) {
    // DashboardProvider dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Utils.defaultText(text: "iNoid Solutions".tr, color: Colors.white),
        actions: [

          // InkWell(
          //   onTap: () {
          //      Get.toNamed(RoutesName.addEmployeeScreen, arguments: {
          //       "is_user_add": true
          //     });
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 16.0),
          //     child: Utils.defaultIcon(icon: Icons.add, color: Colors.white, size: 26),
          //   ),
          // ),

          InkWell(
            onTap: ()=> _showBottomSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Utils.defaultIcon(icon: Icons.settings, color: Colors.white, size: 26),
            ),
          ),

        ],
      ),
      floatingActionButton: _floatingActionButton(),
      body: Consumer<DashboardProvider>(
        builder:(BuildContext context, dashBoardProvider, Widget? child){
          return  StreamBuilder<List<EmployeeModel>>(
            stream: SupaBaseService().fetchAllEmployeesStream(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              print("snapshot connection state is --> ${snapshot.connectionState}");
              if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done){

                print("snapshot has error --> ${snapshot.hasError}");
                if (snapshot.hasError) {
                  return const Text("something went wrong");
                }else if(snapshot.hasData){

                  // final documents = snapshot.data!.docs;
                  // List users = documents.map((doc) {
                  //   return EmployeeModel.fromJson(doc.data() as Map<String, dynamic>);
                  //    //  return UserModel.fromDocument(doc);
                  // }
                  // ).toList();

                  // SharedPref.saveUsers(users);
                  // List<UserModel> user = users.map((dynamic userMap) {
                  //   return UserModel.fromJson(userMap);
                  // }).toList();

                  final arrEmployees = snapshot.data!;
                  print("employee array--> ${arrEmployees.length}");

                  return arrEmployees.isNotEmpty ? ListView.separated(
                    itemCount: arrEmployees.length,
                    itemBuilder: (context, index){
                      // int key = LocalDB.getUserKey(index);
                      // String documentId = documents[index].id;
                      return Slidable(
                        key: UniqueKey(),
                        direction: Axis.horizontal,
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.4,
                          children: [
                            SlidableAction(
                              onPressed: (newContext)=> Get.toNamed(RoutesName.addEmployeeScreen, arguments: {
                                "is_user_add": false,
                                "document_id": arrEmployees[index].id
                              }),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              icon: Icons.edit,
                            ),
                            SlidableAction(
                              onPressed: (newContext)=> Utils.defaultCupertinoDialog(context: context, contentText: "Are you sure you want to remove this employee?",
                                  cancelCallBack: () => Get.back(),
                                  confirmCallback: () {
                                    Get.back();
                                    dashBoardProvider.deleteSingleUser(arrEmployees[index].id, arrEmployees[index].empId, arrEmployees[index].createdAt);
                                  }),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              icon: Icons.delete,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading:
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              // radius: 30,
                              // backgroundColor: Colors.black.withOpacity(0.3),
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3)
                                ),
                                child: (arrEmployees[index].imageUrl != null)
                                    ? CachedNetworkImage(
                                  imageUrl: arrEmployees[index].imageUrl,
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      CircularProgressIndicator(value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => const Icon(Icons.person),
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ) : Image.asset(
                                    AppImages.kPerson,
                                    width: 50,
                                    height: 50)

                            ),
                          ),
                          title: Utils.defaultText(text: arrEmployees[index].name ?? "name of an employee", fontSize: 16, fontWeight: FontWeight.w500),
                          subtitle: Utils.defaultText(text: arrEmployees[index].email ?? "email of an employee", fontWeight: FontWeight.w300),
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
                  )
                      : Center(child: Utils.defaultText(text: 'No Employee added.', fontSize: 20, fontWeight: FontWeight.w600));
                }
              }
              else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Container();
              // return const Text("something went wrong");

            },);
        }

      )

      // body: Selector<DashboardProvider, bool>(
      //   selector: (context, dashBoardProvider) => dashBoardProvider.isLoading,
      //   builder: (context, isLoading, child) {
      //     if(isLoading){
      //       print("loading true");
      //       return const CircularProgressIndicator();
      //     }
      //
      //     print("loading false");
      //     if (dashboardProvider.users.isEmpty) {
      //       return Center(child: Utils.defaultText(text: 'No Employee added.', fontSize: 24, fontWeight: FontWeight.w600));
      //     }
      //
      //     return ListView.separated(
      //       itemCount: dashboardProvider.users.length,
      //       itemBuilder: (context, index){
      //         // int key = LocalDB.getUserKey(index);
      //         return ListTile(
      //           leading: Utils.defaultIcon(icon: Icons.person, color: Colors.black),
      //           title: Utils.defaultText(text: dashboardProvider.users[index].name ?? "name of an employee", fontSize: 16, fontWeight: FontWeight.w500),
      //           subtitle: Utils.defaultText(text: dashboardProvider.users[index].email ?? "email of an employee", fontWeight: FontWeight.w300),
      //           trailing: InkWell(
      //               onTap: () {
      //                 Utils.defaultAlertDialog(contentText: "Are you sure you want to remove this employee?", cancelCallBack: () => Get.back(), confirmCallback: () {
      //                   Get.back();
      //                   dashboardProvider.deleteSingleUser(dashboardProvider.users[index].employeeId.toString());
      //                 });
      //
      //                 // dashboardProvider.deleteSingleUser(key);
      //                 // await LocalDB.deleteUser(key);
      //                 // dashboardProvider.getEmployeeList();
      //
      //               },
      //               child: Utils.defaultIcon(icon: Icons.delete, color: Colors.black)),
      //         );
      //       }, separatorBuilder: (BuildContext context, int index) {
      //       return const Divider(
      //         color: Colors.grey,
      //         indent: 25,
      //         endIndent: 25,
      //       );
      //      },
      //     );
      //   }
      // )

    );
  }

  Widget _floatingActionButton(){
    return FloatingActionButton(
        onPressed: ()=> Get.toNamed(RoutesName.cameraDetectionScreen, arguments: {
          "is_new_user": false,
        }),
    child: Utils.defaultIcon(icon: Icons.camera, color: Colors.black));
  }

  Future _showBottomSheet(BuildContext context) {
    DashboardProvider dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    return showModalBottomSheet(
        context: context,
        elevation: 8.0,
        isDismissible: true,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))
        ),
        builder: (BuildContext ctx) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.black
                  ),
                ),
                const SizedBox(height: 30.0),
                Utils.svgAssetImage(assetPath: AppImages.kCompanyLogo),
                const SizedBox(height: 10.0),
                _buildCommonUi(onTap: () {
                  Get.back();
                  Get.toNamed(RoutesName.addEmployeeScreen, arguments: {
                  "is_user_add": true
                });
                }, text: "Add Employee".tr, imagePath: AppImages.kDevelopment),
                Divider(
                  color: Colors.grey.withOpacity(0.6),
                  indent: 25,
                  height: 0,
                  endIndent: 25,
                ),
                _buildCommonUi(onTap: () {
                  Get.back();
                  Get.toNamed(RoutesName.attendanceRecordScreen);
                }, text: "Attendance Record", imagePath: AppImages.kRecord),
                Divider(
                  color: Colors.grey.withOpacity(0.6),
                  indent: 25,
                  height: 0,
                  endIndent: 25,
                ),
                _buildCommonUi(onTap: () {
                  Get.back();
                  Utils.defaultCupertinoDialog(context: context, contentText: "Are you sure you want to logout?",
                    cancelCallBack: ()=> Get.back(),
                    confirmCallback: () => dashboardProvider.logoutUser(),
                );
                }, text: "Logout", imagePath: AppImages.kLogout),
                const SizedBox(height: 30.0),
                    Utils.defaultText(
                      text: "${"Version: ".tr} ${dashboardProvider.appVersion}",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                )
              ],
            ),
          );
        });
  }

  Widget _buildCommonUi({required String imagePath, required String text, required Function onTap}){
      return InkWell(
        onTap: (){
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                  children: [
                    Image.asset(imagePath, height: 24.0, width: 24.0, fit: BoxFit.fill, color: Colors.black,),
                    const SizedBox(width: 15.0),
                    Utils.defaultText(text: text, fontSize: 16, fontWeight: FontWeight.w400, color:Colors.black),
                  ]),
              Utils.defaultIcon(icon: Icons.chevron_right, color: Colors.black, size: 26),
            ],
          ),
        ),
      );
    }


}
