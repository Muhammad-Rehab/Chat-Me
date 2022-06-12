

import 'dart:io';

import 'chat_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MyProfileProvider extends ChangeNotifier {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map<String, String> editingUserData = {
    'firsName': '',
    'lastName': '',
    'status': ''
  };
  File? image;
  String imageURL = '';

  updateData(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      notifyListeners();
      return;
    }
    formKey.currentState!.save();
    try {
      await FirebaseFirestore.instance
          .doc('users/${Provider
          .of<ChatProvider>(context, listen: false)
          .currentUserData!
          .id}')
          .update(editingUserData);
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(
              AppLocalizations.of(context)!.myProfileSnackBarContent)));
      notifyListeners();
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text(AppLocalizations.of(context)!
                    .personalEntryScreenErrorDialogTitle),
                content: Text(AppLocalizations.of(context)!
                    .personalEntryScreenErrorDialogContent),
              ));
      notifyListeners();
    }
  }

  pickImage(ImageSource source,BuildContext context) async {
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
    await FirebaseFirestore.instance
        .doc('users/${Provider.of<ChatProvider>(context,listen: false).currentUserData!.id}')
        .update({
      'personalImage': imageURL,
    });
    notifyListeners();
  }



}