import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/Utils/utils/validation.dart';
import 'package:google_ml_face_detection/models/employee_model.dart';
import 'package:google_ml_face_detection/provider/add_employee_provider/add_employee_provider.dart';
import 'package:provider/provider.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  bool isUserAdd = true;
  int? id;
  var argumentData = Get.arguments;

  @override
  void initState() {
    isUserAdd = argumentData["is_user_add"];
    AddEmployeeProvider addEmployeeProvider = Provider.of<AddEmployeeProvider>(context, listen: false);
    addEmployeeProvider.clearProviderValues();
    if(!isUserAdd) {
      id = argumentData["document_id"];
      if(id!=null) {
        addEmployeeProvider.fetchSingleEmployeeData(id: id!);
      }
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    const double mirror = math.pi;

    return GestureDetector(
      onTap: ()=> CommonMethodsClass.closeKeyboard(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Utils.defaultText(text: isUserAdd ? "Add Employee" : "Edit Employee", color: Colors.white),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: InkWell(
              onTap: ()=> Get.back(),
              child: Utils.defaultIcon(icon: Icons.chevron_left, color: Colors.white, size: 26)),
        ),
        body: Consumer<AddEmployeeProvider>(
          builder: (BuildContext context, addEmployeeProvider, Widget? child) {
           return SingleChildScrollView(
             child: Padding(
               padding: const EdgeInsets.all(30),
               child: Form(
                 key: addEmployeeProvider.formKey,
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     sizedBoxHeight_20,

                     InkWell(
                       borderRadius: BorderRadius.circular(90),
                       onTap: () async {
                         CommonMethodsClass.closeKeyboard(context);
                         var result = await Get.toNamed(RoutesName.cameraDetectionScreen, arguments: {
                           "is_new_user": true,
                         });
                         addEmployeeProvider.predictedArray = result["predicated_image_data"];
                         print("predicted array is: ${addEmployeeProvider.predictedArray}");
                         String? image = result["image_path"];
                         if(image!=null) {
                           addEmployeeProvider.updateProfile(image);
                         }
                       },
                       child: ClipRRect(
                           borderRadius: BorderRadius.circular(90),
                           child: Container(
                               height: 180,
                               width: 180,
                             decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(90),
                               border: Border.all(color: Colors.grey, width: 1.5)
                             ),
                             alignment: Alignment.center,
                             child: (addEmployeeProvider.imageNetworkUrl != null)
                                 ? CachedNetworkImage(
                                   imageUrl: addEmployeeProvider.imageNetworkUrl!,
                                   progressIndicatorBuilder: (context, url, downloadProgress) =>
                                   CircularProgressIndicator(value: downloadProgress.progress),
                                   errorWidget: (context, url, error) => const Icon(Icons.error),
                                   fit: BoxFit.cover,
                                   height: 180,
                                   width: 180,
                                   )
                                    : (addEmployeeProvider.imagePath != null) ?
                                       Transform(
                                 alignment: Alignment.center,
                                 transform: Matrix4.rotationY(mirror),
                                 child: Image.file(File(addEmployeeProvider.imagePath!), height: 180,
                                     width: 180, fit: BoxFit.cover)) :
                                        Image.asset(AppImages.kUpload, height: 60, width: 60, fit: BoxFit.cover)

                           )
                       ),
                     ),
                     sizedBoxHeight_25,

                     // Selector<AddEmployeeProvider, String?>(
                     //     selector: (context, addEmployeeProvider) => addEmployeeProvider.imagePath,
                     //     builder: (context, imagePath, child){
                     //       return InkWell(
                     //         onTap: () async {
                     //           CommonMethodsClass.closeKeyboard(context);
                     //           var result = await Get.toNamed(RoutesName.cameraDetectionScreen, arguments: {
                     //             "is_new_user": true,
                     //           });
                     //           addEmployeeProvider.predictedArray = result["predicated_image_data"];
                     //           String image = result["image_path"];
                     //           addEmployeeProvider.updateProfile(image);
                     //           print("predicted array is: ${addEmployeeProvider.predictedArray}");
                     //         },
                     //         child: ClipRRect(
                     //             borderRadius: BorderRadius.circular(90),
                     //             child: Container(
                     //               height: 180,
                     //               width: 180,
                     //               decoration: BoxDecoration(
                     //                   color: Colors.black.withOpacity(0.3)
                     //               ),
                     //               child: (imagePath == null) ?
                     //               Image.asset("assets/person.png") : Transform(
                     //                   alignment: Alignment.center,
                     //                   transform: Matrix4.rotationY(mirror),
                     //                   child: Image.file(File(imagePath), fit: BoxFit.cover)),
                     //             )
                     //         ),
                     //       );
                     //     }
                     // ),

                     /// Employee id text field
                     Utils.defaultTextFormField(
                         controller: addEmployeeProvider.employeeIdController,
                         validationCallback: (value)=> Validation.employeeIdValidation(value),
                         hintText: "Enter Employee Id",
                         labelText: "Employee Id",
                         textInputType: TextInputType.text,
                         prefix: Utils.defaultIcon(icon :Icons.person, color: Colors.grey),
                         textInputAction: TextInputAction.next,
                     ),
                     sizedBoxHeight_25,

                     /// Employee name field
                     Utils.defaultTextFormField(
                         controller: addEmployeeProvider.nameController,
                         validationCallback: (value)=> Validation.nameValidation(value),
                         hintText: "Enter Employee Name",
                         labelText: "Employee Name",
                         textInputFormatter: [capitalizedFirstLetterFormatter],
                         textInputType: TextInputType.text,
                         prefix: Utils.defaultIcon(icon :Icons.person, color: Colors.grey),
                         textInputAction: TextInputAction.next,
                     ),
                     sizedBoxHeight_25,

                     /// Employee email field
                     Utils.defaultTextFormField(
                         controller: addEmployeeProvider.emailController,
                         validationCallback: (value)=> Validation.emailValidation(value),
                         hintText: "Enter Employee Email",
                         labelText: "Employee Email",
                         textInputType: TextInputType.emailAddress,
                         prefix: Utils.defaultIcon(icon :Icons.email, color: Colors.grey),
                         textInputAction: TextInputAction.done,
                     ),
                     sizedBoxHeight_25,

                     // Utils.defaultElevatedButton(
                     //     onPressed: () async {
                     //       CommonMethodsClass.closeKeyboard(context);
                     //       var result = await Get.toNamed(RoutesName.cameraDetectionScreen, arguments: {
                     //         "is_new_user": true,
                     //       });
                     //       predictedArray = result["predicated_image_data"];
                     //       String image = result["image_path"];
                     //       addEmployeeProvider.updateProfile(image);
                     //       print("predicted array is: $predictedArray");
                     //     }, buttonText: 'Take Selfie', buttonBackgroundColor: Colors.black, textColor: Colors.white, fontSize: 20
                     // ),
                     // sizedBoxHeight_25,

                     Utils.defaultElevatedButton(
                         onPressed: () async {

                           if(addEmployeeProvider.formKey.currentState!.validate()){
                             if(addEmployeeProvider.predictedArray!=null && (addEmployeeProvider.imagePath!=null || addEmployeeProvider.imageNetworkUrl!=null)){
                               EmployeeModel user = EmployeeModel(
                                   // id: const Uuid().v1(),
                                   empId: addEmployeeProvider.employeeIdController.text.trim(),
                                   name: addEmployeeProvider.nameController.text.trim(),
                                   email: addEmployeeProvider.emailController.text.trim(),
                                   imageData: addEmployeeProvider.predictedArray,
                                   createdAt: DateTime.now().toIso8601String(),
                               );
                               if(isUserAdd) {
                                   addEmployeeProvider.setUserDetails(user);
                               }else{
                                 if(id!=null) {
                                   addEmployeeProvider.updateUserDetails(user, id!);
                                 }
                               }
                             }else{
                               Utils.defaultFlutterToast(text: "Please add employee photo for face detection");
                             }
                           }
                         }, buttonText: 'Save'.tr, buttonBackgroundColor: Colors.black, textColor: Colors.white, fontSize: 20
                     )

                   ],
                 ),
               ),
             ),
           );
          }
          ),
      ),
    );
  }


  // TextInputFormatter to automatically capitalize the first letter
  final TextInputFormatter capitalizedFirstLetterFormatter = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      // Capitalize the first letter
      if (newValue.text.isNotEmpty && newValue.text.length == 1) {
        return TextEditingValue(
          text: newValue.text.toUpperCase(),
          selection: const TextSelection.collapsed(offset: 1),
        );
      }
      return newValue;
    },
  );


}
