import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../model/user.dart';
import 'audio_provider.dart';

class MessageProvider extends ChangeNotifier {

  final textController = TextEditingController();
  String currentMessage = '';
  String temporaryCurrentMessage = '';
  bool showEmoji = false;
  bool isFilePicked = false;
  String messageType = 'String';
  bool isFileUploading = false;
  bool textFieldEnabled = true;
  bool showDownloadIndicator = false;
  List<Map<String, dynamic>> chatData = [];
  List<Map<String, dynamic>> chatList = [];
  bool isChatEmpty = false;
  String currentChatItemID = '';
  AnimationController? controller;
  double sliderValue = 0;
  Users? currentUserData;
  var arguments;
  int sliderIndex = -1;

  Timer timer = Timer(Duration.zero, () {});
  FilePickerResult? result;

  sendMessage(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      textController.clear();
      temporaryCurrentMessage = currentMessage;
      int _audioLength = Provider.of<Audio>(context, listen: false).audioLength;
      currentMessage = '';
      showEmoji = false;
      isFilePicked = false;

      if (Provider.of<Audio>(context, listen: false).recordingPath.isNotEmpty) {
        await Provider.of<Audio>(context, listen: false).sendRecord();
        temporaryCurrentMessage =
            Provider.of<Audio>(context, listen: false).recordingPath;
        messageType = 'Record';
        Provider.of<Audio>(context, listen: false).stopRecording();
        notifyListeners();
      }

      await FirebaseFirestore.instance
          .collection('chats/${currentUserData!.phoneNumber}'
              '/${arguments['userData'].phoneNumber}')
          .add({}).then((value) {
        FirebaseFirestore.instance
            .doc('chats/${currentUserData!.phoneNumber}'
                '/${arguments['userData'].phoneNumber}/${value.id}')
            .update({
          'filePath': temporaryCurrentMessage,
          'message': temporaryCurrentMessage,
          'time': Timestamp.now(),
          'sentFrom': {
            'activity': currentUserData!.activity,
            'firsName': currentUserData!.firstName,
            'lastName': currentUserData!.lastName,
            'id': currentUserData!.id,
            'personalImage': currentUserData!.personalImage,
            'phoneNumber': currentUserData!.phoneNumber,
            'status': currentUserData!.status,
          },
          'sentTo': {
            'activity': arguments['userData'].activity,
            'firsName': arguments['userData'].firstName,
            'lastName': arguments['userData'].lastName,
            'id': arguments['userData'].id,
            'personalImage': arguments['userData'].personalImage,
            'phoneNumber': arguments['userData'].phoneNumber,
            'status': arguments['userData'].status,
          },
          'messageID': value.id,
          'messageType': messageType,
          'recordLength': _audioLength,
        });
        FirebaseFirestore.instance
            .doc('chats/${arguments['userData'].phoneNumber}/'
                '${currentUserData!.phoneNumber}/${value.id}')
            .set({
          'filePath': temporaryCurrentMessage,
          'message': temporaryCurrentMessage,
          'time': Timestamp.now(),
          'sentFrom': {
            'activity': currentUserData!.activity,
            'firsName': currentUserData!.firstName,
            'lastName': currentUserData!.lastName,
            'id': currentUserData!.id,
            'personalImage': currentUserData!.personalImage,
            'phoneNumber': currentUserData!.phoneNumber,
            'status': currentUserData!.status,
          },
          'sentTo': {
            'activity': arguments['userData'].activity,
            'firsName': arguments['userData'].firstName,
            'lastName': arguments['userData'].lastName,
            'id': arguments['userData'].id,
            'personalImage': arguments['userData'].personalImage,
            'phoneNumber': arguments['userData'].phoneNumber,
            'status': arguments['userData'].status,
          },
          'messageID': value.id,
          'messageType': messageType,
          'recordLength': _audioLength,
        });
        if (messageType == 'File') {
          downloadFile({
            'filePath': temporaryCurrentMessage,
            'message': temporaryCurrentMessage,
            'sentFrom': {
              'activity': currentUserData!.activity,
              'firsName': currentUserData!.firstName,
              'lastName': currentUserData!.lastName,
              'id': currentUserData!.id,
              'personalImage': currentUserData!.personalImage,
              'phoneNumber': currentUserData!.phoneNumber,
              'status': currentUserData!.status,
            },
            'messageID': value.id,
          }, arguments['userData'].phoneNumber, currentUserData!, context);
        }
        if (messageType == 'Record') {
          Provider.of<Audio>(context, listen: false).downloadRecord({
            'filePath': temporaryCurrentMessage,
            'message': temporaryCurrentMessage,
            'sentFrom': {
              'activity': currentUserData!.activity,
              'firsName': currentUserData!.firstName,
              'lastName': currentUserData!.lastName,
              'id': currentUserData!.id,
              'personalImage': currentUserData!.personalImage,
              'phoneNumber': currentUserData!.phoneNumber,
              'status': currentUserData!.status,
            },
            'messageID': value.id,
          }, arguments['userData'].phoneNumber, currentUserData!);
        }
      });
      messageType = 'String';
      textFieldEnabled = true;
      showDownloadIndicator = false;
      chatList = (await FirebaseFirestore.instance
              .collection(
                  'chatList/${FirebaseAuth.instance.currentUser!.phoneNumber}/'
                  '${FirebaseAuth.instance.currentUser!.phoneNumber}')
              .get())
          .docs
          .map((e) => e.data())
          .toList();

      if (!chatList.any((element) =>
          element['phoneNumber'] == arguments['userData'].phoneNumber)) {
        FirebaseFirestore.instance
            .collection(
                'chatList/${FirebaseAuth.instance.currentUser!.phoneNumber}/'
                '${FirebaseAuth.instance.currentUser!.phoneNumber}')
            .add({}).then((value) {
          FirebaseFirestore.instance
              .doc('chatList/${FirebaseAuth.instance.currentUser!.phoneNumber}/'
                  '${FirebaseAuth.instance.currentUser!.phoneNumber}/${value.id}')
              .update({
            'phoneNumber': arguments['userData'].phoneNumber.toString(),
            'id': value.id
          });
          FirebaseFirestore.instance
              .doc('chatList/${arguments['userData'].phoneNumber}/'
                  '${arguments['userData'].phoneNumber}/${value.id}')
              .set({
            'phoneNumber': FirebaseAuth.instance.currentUser!.phoneNumber,
            'id': value.id
          });
        });
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  downloadFile(Map<String, dynamic> message, String sendTo,
      Users currentUserData, BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      String ref = FirebaseStorage.instance.ref('${message['filePath']}').name;
      await FirebaseStorage.instance
          .ref('${message['filePath']}')
          .writeToFile(File('${dir.path}/$ref'));
      Toast.show(
        'Downloaded File $ref',
      );
      if (sendTo == currentUserData.phoneNumber) {
        await FirebaseFirestore.instance
            .doc(
                'chats/${message['sentFrom']['phoneNumber']}/$sendTo/${message['messageID']}')
            .update({
          'receiverFilePath': '${dir.path}/$ref',
          'messageType': 'File Saved 2',
        });
        await FirebaseFirestore.instance
            .doc(
                'chats/$sendTo/${message['sentFrom']['phoneNumber']}/${message['messageID']}')
            .update({
          'receiverFilePath': '${dir.path}/$ref',
          'messageType': 'File Saved 2',
        }).then((value) {
          showDownloadIndicator = false;
        });
      } else {
        await FirebaseFirestore.instance
            .doc(
                'chats/${message['sentFrom']['phoneNumber']}/$sendTo/${message['messageID']}')
            .update({
          'message': '${dir.path}/$ref',
          'messageType': 'File Saved',
        });
        await FirebaseFirestore.instance
            .doc(
                'chats/$sendTo/${message['sentFrom']['phoneNumber']}/${message['messageID']}')
            .update({
          'message': '${dir.path}/$ref',
          'messageType': 'File Saved',
        }).then((value) {
          showDownloadIndicator = false;
        });
      }
      notifyListeners();
    } catch (e) {
      Toast.show('Something wrong try again later');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text(e.toString()),
              ));
      showDownloadIndicator = false;
    }
    notifyListeners();
  }

  deleteMessage(Map<String, dynamic> message) async {
    try {
      await FirebaseFirestore.instance
          .doc('chats/${currentUserData!.phoneNumber}'
              '/${arguments['userData'].phoneNumber}/${message['messageID']}')
          .delete();
      await FirebaseFirestore.instance
          .doc('chats/${arguments['userData'].phoneNumber}'
              '/${currentUserData!.phoneNumber}/${message['messageID']}')
          .delete();
      notifyListeners();
    } catch (e) {
      Toast.show('Something wrong try again later ');
      notifyListeners();
    }
  }

  sendFile() async {
    try {
      result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      final key = UniqueKey().toString();
      final _file = File(result!.paths.first.toString());
      isFileUploading = true;
      textFieldEnabled = false;
      await FirebaseStorage.instance
          .ref('files/$key/${result!.files.first.name}')
          .putFile(_file);
      String fileUrl = FirebaseStorage.instance
          .ref('files/$key/${result!.files.first.name}')
          .fullPath;

      currentMessage = fileUrl;
      isFileUploading = false;
      isFilePicked = true;
      messageType = 'File';
      notifyListeners();
    } catch (e) {
      Toast.show('Something wrong try again later');
      notifyListeners();
    }
  }


}
