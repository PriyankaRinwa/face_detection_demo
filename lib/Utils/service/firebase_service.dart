// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:google_ml_face_detection/Utils/shared_preference/shared_prefrence.dart';
// import 'package:google_ml_face_detection/Utils/utils/utils.dart';
// import 'package:google_ml_face_detection/models/employee_model.dart';
// import 'package:intl/intl.dart';
//
// class FirebaseService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//  // Register with Email and Password
//   Future<String?> registerWithEmail(String email, String password) async {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // Get the signed-in user
//       User? user = userCredential.user;
//
//       // Store additional user info in Firestore
//       if (user != null) {
//         SharedPref.setUid(user.uid);
//         await _firestore.collection('users').doc(user.uid).set({
//           'uid': user.uid,
//           'email': email,
//           'createdAt': FieldValue.serverTimestamp(),
//          // 'createdAt': FieldValue.serverTimestamp(),
//           "passcode": ""
//         });
//
//         // var uuid = const Uuid().v1();
//         await _firestore.collection('email').add({
//           'email': email,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//
//       }
//
//       // _firestore.collection('users/user.uid/employee').doc("employee_id").set({
//       //   "employee_id": ,
//       //   "name": ,
//       //   "email": ,
//       //   "image_data_array": ,
//       // });
//
//       return null; // Success
//   }
//
//   Future<String> signInWithEmail(String email, String password) async {
//     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // Get the signed-in user
//       User? user = userCredential.user;
//       String passcode = "";
//
//       // Store additional user info in Firestore
//       if (user != null) {
//         SharedPref.setUid(user.uid);
//         passcode = await getPasscode(user.uid)??"";
//       }
//
//       return passcode;
//
//       // _firestore.collection('users/user.uid/employee').doc("employee_id").set({
//       //   "employee_id": ,
//       //   "name": ,
//       //   "email": ,
//       //   "image_data_array": ,
//       // });
//
//   }
//
//   Future<Map<String, dynamic>?> getSingleUserData() async {
//     // try {
//     //   DocumentSnapshot docSnapshot = await _firestore.collection('otp').doc("1").get();
//     //   if (docSnapshot.exists) {
//     //     return docSnapshot.data() as Map<String, dynamic>; // Cast to a Map
//     //   } else {
//     //     print('Otp not found');
//     //     return null; // Document doesn't exist
//     //   }
//     // } on FirebaseAuthException catch (e) {
//     //   print('Error fetching otp: $e');
//     //   return null;
//     // }
//
//     // try {
//       DocumentSnapshot docSnapshot = await _firestore.collection('users').doc("l7UJ9FYCefbyFWZoGBT83rJlrSi2").get();
//       if (docSnapshot.exists) {
//         return docSnapshot.data() as Map<String, dynamic>; // Cast to a Map
//       } else {
//         print('user data not found');
//         return null; // Document doesn't exist
//       }
//     // } catch (e) {
//     //   print('Error fetching otp: $e');
//     //   return null;
//     // }
//
//   }
//
//   Future<String?> setPasscode(String passcode) async {
//    // try {
//       String uid = await SharedPref.getUid();
//       await _firestore.collection('users').doc(uid).update({
//         'passcode': passcode,
//       });
//       return null;
//     // } on FirebaseAuthException catch (e) {
//     //   return e.message; // Return error message
//     // }
//   }
//
//   Future<String?> getPasscode(String uid) async {
//       DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(uid).get();
//       if (docSnapshot.exists) {
//         var data = docSnapshot.data() as Map<String, dynamic>;
//         return data["passcode"];
//         // Cast to a Map
//       } else {
//         print('docSnapshot not found');
//         return null; // Document doesn't exist
//       }
//   }
//
//   // Fetch all users
//   Future<List<Map<String, dynamic>>> fetchUsersEmail() async {
//     try {
//       QuerySnapshot querySnapshot = await _firestore.collection('email').get();
//
//       // Convert each document into a map
//       return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//     } catch (e) {
//       print(e);
//       return [];
//     }
//   }
//
//
//   Future<void> setEmployeeData(EmployeeModel employeeModel) async {
//     // String uid = await SharedPref.getUid();
//     // await _firestore.collection('users/$uid/employees').add({
//     //   'id': const Uuid().v1(),
//     //   'name': user.name,
//     //   'email': user.email,
//     //   "image_data_array": user.imageDataArray
//     // });
//
//
//     await _firestore.collection('employees').add(employeeModel.toJson());
//
//   }
//
//   Future<void> updateEmployeeData(EmployeeModel employeeModel, String documentId) async {
//     await _firestore.collection('employees').doc(documentId).update(employeeModel.toJson());
//   }
//
//   // Fetch all users
//   Future<List<EmployeeModel>> fetchAllEmployeeDetails() async {
//     try {
//       // String uid = await SharedPref.getUid();
//       QuerySnapshot querySnapshot = await _firestore.collection('employees').get();
//
//       // Convert each document into a map
//       return querySnapshot.docs.map((doc) {
//         // var res = doc.data() as Map<String, dynamic>;
//         // UserModel user = UserModel.fromJson(res);
//         EmployeeModel user = EmployeeModel.fromDocument(doc);
//         return user;
//       }).toList();
//
//     } catch (e) {
//       print(e);
//       return [];
//     }
//   }
//
//   Future<List<EmployeeModel>> fetchAllEmployeeDetailsExceptOwn(String documentId) async {
//     try {
//       // String uid = await SharedPref.getUid();
//       QuerySnapshot querySnapshot = await _firestore.collection('employees').where("employeeDocumentId", isNotEqualTo:documentId).get();
//
//       // Convert each document into a map
//       return querySnapshot.docs.map((doc) {
//         // var res = doc.data() as Map<String, dynamic>;
//         // UserModel user = UserModel.fromJson(res);
//         EmployeeModel user = EmployeeModel.fromDocument(doc);
//         return user;
//       }).toList();
//
//     } catch (e) {
//       print(e);
//       return [];
//     }
//   }
//
//   Stream<QuerySnapshot<Map<String, dynamic>>> fetchEmployeeDetails() {
//     return _firestore.collection('employees').snapshots();
//   }
//
//   Future<void> deleteSingleEmployeeData(String documentId) async {
//     await _firestore.collection('employees').doc(documentId).delete();
//   }
//
//   Future<void> addEmployeeAttendanceRecord(BuildContext context, EmployeeModel employeeModel, VoidCallback? voidCallback) async {
//
//     // int type = 0; /// 0 for clock out
//     // if(user.type==0){
//     //   type = 1; /// 1 for clock out
//     // }
//
//     QuerySnapshot querySnapshot = await _firestore.collection('attendances').where("id", isEqualTo: employeeModel.id).orderBy('created_at', descending: false).get();
//
//     int type = 0;
//     if(querySnapshot.docs.isNotEmpty) {
//       if (querySnapshot.docs.last.exists) {
//         type = querySnapshot.docs.last.get("type");
//         if (type == 0) {
//           type = 1;
//         } else {
//           type = 0;
//         }
//       }
//     }
//
//     Map<String, dynamic> data = {
//       "name": employeeModel.name,
//       "id": employeeModel.id,
//       "type": type,
//       'created_at': FieldValue.serverTimestamp(),
//     };
//
//     await _firestore.collection('attendances').add(data).then((value) {
//       // Timestamp timestamp = FieldValue.serverTimestamp();
//       DateTime dateTime = DateTime.now();
//       String formattedTime = DateFormat('hh:mm:ss a').format(dateTime);
//
//       if(type==0) {
//         Utils.defaultCupertinoDialog(context: context, contentText: "You are successfully clock in at: $formattedTime",
//             titleText: "Thankyou!",
//             confirmCallback: () {
//               Get.back();
//               if(voidCallback!=null) voidCallback();
//              }
//             );
//       }else{
//         Utils.defaultCupertinoDialog(context: context, contentText: "You are successfully clock out at $formattedTime",
//             titleText: "Thankyou!",
//             confirmCallback: () {
//               Get.back();
//               if(voidCallback!=null) voidCallback();
//             }
//         );
//       }
//       }
//     );
//   }
//
//   Future<String?> uploadImage(File imageFile) async {
//     try {
//       // Create a reference to the storage location
//       String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
//       Reference storageRef = _storage.ref().child(fileName);
//
//       // Upload the file
//       UploadTask uploadTask = storageRef.putFile(imageFile);
//       await uploadTask;
//
//       // Get the download URL
//       String downloadURL = await storageRef.getDownloadURL();
//       return downloadURL; // Return the download URL of the image
//     } catch (e) {
//       print("Error uploading image: $e");
//       return null;
//     }
//   }
//
//   Future<EmployeeModel?> getSingleEmployeeData(String? documentId) async {
//     DocumentSnapshot docSnapshot = await _firestore.collection('employees').doc(documentId).get();
//     if (docSnapshot.exists) {
//       EmployeeModel user = EmployeeModel.fromDocument(docSnapshot);
//       return user;
//     } else {
//       print('user data not found');
//       return null; // Document doesn't exist
//     }
//   }
//
//   Stream<QuerySnapshot<Map<String, dynamic>>> fetchSingleDayEmployeeRecords({required DateTime selectedDate}) {
//
//     DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//     DateTime endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)); // Just before midnight
//
//     // Convert DateTime to Firestore Timestamp
//     Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
//     Timestamp endTimestamp = Timestamp.fromDate(endOfDay);
//
//     // Query Firestore for documents where 'date' is within the selected day range
//     Stream<QuerySnapshot<Map<String, dynamic>>> stream =  _firestore
//         .collection('attendances') // Replace with your collection name
//         .where('created_at', isGreaterThanOrEqualTo: startTimestamp)
//         .where('created_at', isLessThanOrEqualTo: endTimestamp)
//         .snapshots();
//
//     return stream;
//   }
//
//   // Sign Out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
//
//
// }