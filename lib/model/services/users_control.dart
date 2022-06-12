
import 'package:chat_me/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersControl {


 static getUsers () async {
    (await FirebaseFirestore.instance.collection('users').get())
        .docs
        .forEach((e) {
          if(usersList.any((element) => (element.id==e.data()['id']))){}else{
            usersList.add(Users(
              e.data()['id'],
              e.data()['activity'],
              e.data()['firsName'],
              e.data()['lastName'],
              e.data()['personalImage'],
              e.data()['phoneNumber'],
              e.data()['status'],
            ));
          }
    });
    return usersList ;
  }

}