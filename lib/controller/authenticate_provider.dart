import 'package:chat_me/model/user.dart';
import 'package:chat_me/view/main_pages/my_profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../model/services/users_control.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider extends ChangeNotifier {
  String verificationID = '';
  int? resendToken;


  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isTimeOut = false;

  User? getCurrentUser(){
    var currentUser = FirebaseAuth.instance.currentUser ;
    return currentUser ;
  }
  logIn(String phoneNumber, BuildContext context) async {
    auth.verifyPhoneNumber(
        phoneNumber: '+2$phoneNumber',
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.code),
          ));
        },
        codeSent: (String id, int? resendToken) async {
          verificationID = id;
          resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String id) {
          isTimeOut = true;
        });
    notifyListeners();
  }

  verifyPhoneAuth(String smsCode, BuildContext context) async {
    UserCredential credential =
        await auth.signInWithCredential(PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: smsCode,
    ),
        );
    if (credential.user != null) {
      Scaffold.of(context).showSnackBar(
          const SnackBar(content: Text('Verification Succeeded')));
      if (await isDataExist()) {
        await FirebaseFirestore.instance
            .doc('users/${FirebaseAuth.instance.currentUser!.uid}')
            .update({
          'appToken': await FirebaseMessaging.instance.getToken() ?? '',
        });
      }
    }
    notifyListeners();
  }

  Future<bool> isDataExist() async {
    await UsersControl.getUsers();
    if (usersList.isEmpty) {
      return false;
    }
    bool isPersonalDataExist = usersList.any((element) =>
        element.phoneNumber == FirebaseAuth.instance.currentUser!.phoneNumber);
    notifyListeners();
    return isPersonalDataExist;
  }

  logOut() async {
    await FirebaseFirestore.instance
        .doc('users/${FirebaseAuth.instance.currentUser!.uid}')
        .update({
      'activity': 'Inactive',
      'appToken': '',
    });
    await auth.signOut();
    MyProfile.imagesUrlList.clear();
    notifyListeners();
  }
}
