
import 'package:chat_me/model/messages.dart';
import 'package:chat_me/model/services/messages_control.dart';
import 'package:chat_me/model/user.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/services/users_control.dart';

class ChatProvider extends ChangeNotifier {


  final Map<String,Messages> _currentChatUsersList = {};

  Users ? currentUserData;
  List<Users> data = [];
  List<Users> currentList = [];

   getHomeData() async {
    await UsersControl.getUsers();
    if(usersList.isEmpty){
      notifyListeners();
      return ;
    }
    data = usersList ;
    currentUserData = data.firstWhere((element) => (element.phoneNumber==FirebaseAuth.instance.currentUser!.phoneNumber));
    data.removeWhere((element) => element.phoneNumber== FirebaseAuth.instance.currentUser!.phoneNumber);
     notifyListeners();
     return data ;
  }

  String getDate(DateTime time,BuildContext context) {
    Duration timeDifference = DateTime.now().difference(time);
    if (timeDifference > const Duration(days: 365)) {
      int years = (timeDifference.inDays / 365).round();
      return '$years ${AppLocalizations.of(context)!.year}';
    } else if (timeDifference > const Duration(days: 30)) {
      int months = (timeDifference.inDays / 30).round();
      return '$months ${AppLocalizations.of(context)!.month}';
    } else if (timeDifference > const Duration(days: 7)) {
      int weeks = (timeDifference.inDays / 7).round();
      return '$weeks ${AppLocalizations.of(context)!.weeks}';
    } else if (timeDifference > const Duration(days: 1)) {
      return '${timeDifference.inDays} ${AppLocalizations.of(context)!.days}';
    } else if (timeDifference > const Duration(hours: 1)) {
      return '${timeDifference.inHours} ${AppLocalizations.of(context)!.hours}';
    } else if (timeDifference > const Duration(minutes: 1)) {
      return '${timeDifference.inMinutes} ${AppLocalizations.of(context)!.minutes}';
    } else {
      return AppLocalizations.of(context)!.now;
    }
  }

   Future<String> getUserActivity(String userID) async {

    return  (await FirebaseFirestore.instance.doc('users/$userID').get())
      .data()!['activity'] ;
  }

  Future<List<Messages>> getChatData() async {
    (await FirebaseFirestore.instance.collection(
        'chatList/${FirebaseAuth.instance.currentUser!.phoneNumber}/'
            '${FirebaseAuth.instance.currentUser!.phoneNumber}').get())
        .docs.forEach((element) async {
          await MessagesControl.getCurrentMessage('${FirebaseAuth.instance.currentUser!.phoneNumber}', '${element.data()['phoneNumber']}');
          if(currentMessage==null){
            return ;
          }
      if(!_currentChatUsersList.keys.toList().contains(element.data()['phoneNumber'])){
      _currentChatUsersList.addAll({
        element.data()['phoneNumber'] : currentMessage!
      });
      notifyListeners();
      }
      else {
      _currentChatUsersList.update(element.data()['phoneNumber'], (value) => currentMessage!);
      notifyListeners();
      }
    });
   currentChatUsersList = _currentChatUsersList.values.toList();
   currentChatUsersList.sort((a,b)=>a.time.compareTo(b.time));
   currentChatUsersList = currentChatUsersList.reversed.toList();
   notifyListeners();
    return currentChatUsersList;
  }

  clearData(){
    _currentChatUsersList.clear();
    currentChatUsersList.clear();
    currentMessage = null ;
    notifyListeners();
  }

}