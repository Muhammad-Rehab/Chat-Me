
import 'package:chat_me/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Messages ? currentMessage ;
List<Messages> currentChatUsersList = [];

class Messages {
  String _filePath = '';
  String _message = '';
  String _messageID = '';
  String _messageType = '';
  String _receiverFilePath ='';
  int _recordLength = 0 ;
  Users ? _sentTo ;
  Users ? _sentFrom;
  Timestamp _time = Timestamp(0,0);

  Messages (String filePath,String message,String messageID,Users sentTo,Users sentFrom,Timestamp time ,{String messageType = 'String',String receiverFilePath= '',int recordLength = 0}){
    _filePath = filePath ;
    _message = message ;
    _messageID = messageID;
    _messageType = messageType;
    _receiverFilePath = receiverFilePath ;
    _recordLength = recordLength ;
    _sentTo =sentTo ;
    _sentFrom = sentFrom ;
    _time = time;
  }

  String get filePath => _filePath ;
  String get message => _message ;
  String get messageID => _messageID ;
  String get messageType => _messageType ;
  String get receiverFilePath => _receiverFilePath ;
  int get recordLength => _recordLength ;
  Users get sentTo => _sentTo! ;
  Users get sentFrom => _sentFrom! ;
  Timestamp get time => _time ;



}