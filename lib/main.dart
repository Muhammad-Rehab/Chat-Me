import 'package:chat_me/controller/message_provider.dart';
import 'package:chat_me/controller/personalDataEntry_provider.dart';
import 'package:chat_me/model/services/users_control.dart';
import 'package:chat_me/view/main_pages/myApp.dart';
import 'package:chat_me/controller/authenticate_provider.dart';
import 'package:chat_me/controller/localizations_provider.dart';
import 'package:chat_me/controller/audio_provider.dart';
import 'package:chat_me/controller/theme_provider.dart';
import 'package:chat_me/controller/chat_provider.dart';
import 'package:flutter/services.dart';
import 'controller/myProfile_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  await ThemeProvider.initTheme();
  await LocalizationsProvider.initLocal();
  await UsersControl.getUsers();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => ChatProvider()),
      ChangeNotifierProvider(create: (context) => LocalizationsProvider()),
      ChangeNotifierProvider(create: (context) => Audio()),
      ChangeNotifierProvider(create: (context) => PersonalDataEntryProvider()),
      ChangeNotifierProvider(create: (context) => MyProfileProvider()),
      ChangeNotifierProvider(create: (context) => MessageProvider()),
    ],
    child: MyApp(),
  ));
}
