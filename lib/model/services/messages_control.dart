
import 'package:chat_me/model/messages.dart';
import 'package:chat_me/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesControl {

  static getCurrentMessage (String currentUserPhone , String endUserPhone) async{
   Map<String,dynamic> data =  (await FirebaseFirestore.instance.collection('chats/'
        '$currentUserPhone/$endUserPhone')
        .orderBy('time').get()).docs.last.data();
    currentMessage = Messages(
      data['filePath'],
      data['message'],
      data['messageID'],
      Users(data['sentTo']['id'],
          data['sentTo']['activity'],
          data['sentTo']['firsName'],
          data['sentTo']['lastName'],
          data['sentTo']['personalImage'],
          data['sentTo']['phoneNumber'],
          data['sentTo']['status']),
      Users(data['sentFrom']['id'],
          data['sentFrom']['activity'],
          data['sentFrom']['firsName'],
          data['sentFrom']['lastName'],
          data['sentFrom']['personalImage'],
          data['sentFrom']['phoneNumber'],
          data['sentFrom']['status']),
      data['time'],
      messageType: data['messageType']??'String',
      receiverFilePath: data['receiverFilePath']??'',
      recordLength: data['recordLength']??0,
    );
  }

}