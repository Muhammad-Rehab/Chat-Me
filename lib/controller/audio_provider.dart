import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toast/toast.dart';

import '../model/user.dart';

class Audio extends ChangeNotifier {
  final _myAudioRecorder = FlutterSoundRecorder();
  final _myAudioPlayer = FlutterSoundPlayer();

  String recordingState = '';
  bool isPlaying = false;

  String recordingPath = '';
  int audioLength = 0;

  Timer? _timer;

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  FlutterSoundRecorder get myAudioRecorder => _myAudioRecorder;

  FlutterSoundPlayer get myAudioPlayer => _myAudioPlayer;

  _getRecordingState() {
    if (_myAudioRecorder.isPaused) {
      recordingState = 'isPaused';
    } else if (_myAudioRecorder.isRecording) {
      recordingState = 'isRecording';
    } else if (_myAudioRecorder.isStopped) {
      recordingState = 'isStopped';
    }
    notifyListeners();
  }

  initRecorder() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      await _myAudioRecorder.openAudioSession();
    }
    _getRecordingState();
  }

  disposeRecorder() async {
    await _myAudioRecorder.closeAudioSession();
    _getRecordingState();
    recordingPath = '';
    _timer!.cancel();
    audioLength = 0;
    notifyListeners();
  }

  Future startRecording() async {
    if (_myAudioRecorder.isPaused) {
      await _myAudioRecorder.resumeRecorder();
    } else {
      final dir = await getApplicationDocumentsDirectory();
      recordingPath = '${dir.path}/chat_recording.aac';
      await _myAudioRecorder.startRecorder(
        toFile: recordingPath,
      );
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      audioLength++;
      notifyListeners();
    });
    notifyListeners();
  }

  Future pauseRecording() async {
    await _myAudioRecorder.pauseRecorder();
    _timer!.cancel();
  }

  Future toggleRecording() async {
    if (_myAudioRecorder.isRecording) {
      await pauseRecording();
    } else {
      await startRecording();
    }
    _getRecordingState();
  }

  Future stopRecording() async {
    await _myAudioRecorder.stopRecorder();
    _getRecordingState();
    recordingPath = '';
    _timer!.cancel();
    audioLength = 0;
    notifyListeners();
  }

  Future sendRecord() async {
    final key = UniqueKey().toString();
    await _firebaseStorage
        .ref('Recorders/$key.aac')
        .putFile(File(recordingPath));
    recordingPath = _firebaseStorage.ref('Recorders/$key.aac').fullPath;
    notifyListeners();
  }

  Future downloadRecord(Map<String, dynamic> message, String sendTo,
      Users currentUserData) async {
    final dir = await getApplicationDocumentsDirectory();
    final ref = _firebaseStorage.ref(message['filePath']).name;
    await _firebaseStorage
        .ref(message['filePath'])
        .writeToFile(File('${dir.path}/$ref'));
    Toast.show(
      'Downloaded File $ref',
    );
    if (currentUserData.phoneNumber == sendTo) {
      await _firebaseFirestore
          .doc(
              'chats/${message['sentFrom']['phoneNumber']}/${message['sentTo']['phoneNumber']}/${message['messageID']}')
          .update({
        'receiverFilePath': '${dir.path}/$ref',
        'messageType': 'Record Saved 2',
      });
      await _firebaseFirestore
          .doc('chats/${message['sentTo']['phoneNumber']}/'
              '${message['sentFrom']['phoneNumber']}/${message['messageID']}')
          .update({
        'receiverFilePath': '${dir.path}/$ref',
        'messageType': 'Record Saved 2',
      });
    } else {
      await _firebaseFirestore
          .doc(
              'chats/${currentUserData.phoneNumber}/$sendTo/${message['messageID']}')
          .update({
        'message': '${dir.path}/$ref',
        'messageType': 'Record Saved',
      });
      await _firebaseFirestore
          .doc(
              'chats/$sendTo/${currentUserData.phoneNumber}/${message['messageID']}')
          .update({
        'message': '${dir.path}/$ref',
        'messageType': 'Record Saved',
      });
    }
  }

  initPlayer() async {
    await _myAudioPlayer.openAudioSession();
    notifyListeners();
  }

  disposePlayer() async {
    await _myAudioPlayer.closeAudioSession();
    notifyListeners();
  }

  Future stopPlayer() async {
    await _myAudioPlayer.stopPlayer();
  }

  Future startPlayer(String path, VoidCallback fn) async {
    await _myAudioPlayer.startPlayer(
      fromURI: path,
      whenFinished: fn,
    );
  }

  togglePlayer(String path, VoidCallback fn) {
    if (_myAudioPlayer.isPlaying) {
      stopPlayer();
      isPlaying = false;
    } else {
      startPlayer(path, fn);
      isPlaying = true;
    }
    notifyListeners();
  }
}
