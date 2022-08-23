import 'dart:io';

import 'package:chat_me/model/user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PersonalDataEntryProvider extends ChangeNotifier {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String token = '';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Map<String, String> personalDataMap = {
    'firsName': '',
    'lastName': '',
    'status': '',
  };
  bool isLoading = false;
  File? image;
  String imageURL = '';

  Future<String> getToken() async {
    token = await firebaseMessaging.getToken() ?? '';
    notifyListeners();
    return token;
  }

  submitFunction(BuildContext context) async {
    isLoading = true;
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      isLoading = false;
      notifyListeners();
      return;
    }
    if (image == null || imageURL == '') {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text(AppLocalizations.of(context)!
                    .personalEntryScreenErrorDialogTitle),
                content: Text(AppLocalizations.of(context)!
                    .personalEntryScreenErrorDialogContent),
              ));
      isLoading = false;
      notifyListeners();
      return;
    }
    formKey.currentState!.save();
    try {
      formKey.currentState!.reset();
      getToken();
      Users users = Users(
        FirebaseAuth.instance.currentUser!.uid,
        'Active',
        personalDataMap['firstName']!,
        personalDataMap['lastName']!,
        imageURL,
        FirebaseAuth.instance.currentUser!.phoneNumber!,
        personalDataMap['status'] ?? '',
        appToken: token,
      );
      await FirebaseFirestore.instance
          .doc('users/${FirebaseAuth.instance.currentUser!.uid}')
          .set({
        'phoneNumber': users.phoneNumber,
        'firsName': users.firstName,
        'lastName': users.lastName,
        'status': users.status,
        'personalImage': users.personalImage,
        'id': users.id,
        'activity': users.activity,
        'appToken': users.appToken,
      });
      isLoading = false;
      imageURL = '';
      notifyListeners();
    } catch (e) {
      isLoading = false;
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!
                  .personalEntryScreenErrorDialogTitle),
              content: Text(AppLocalizations.of(context)!
                  .personalEntryScreenErrorDialogContent),
            );
          });
      notifyListeners();
      return;
    }
  }

  pickImage(ImageSource source) async {
    XFile? _image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 30,
    );
    if (_image == null) {
      notifyListeners();
      return;
    }
    final String key = UniqueKey().toString();
    image = File(_image.path);
    await FirebaseStorage.instance
        .ref(
            'images/${FirebaseAuth.instance.currentUser!.phoneNumber}/$key.png')
        .putFile(image!);
    imageURL = await FirebaseStorage.instance
        .ref(
            'images/${FirebaseAuth.instance.currentUser!.phoneNumber}/$key.png')
        .getDownloadURL();

    notifyListeners();
  }
}
