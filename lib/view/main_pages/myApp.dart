import 'package:chat_me/model/user.dart';
import 'package:chat_me/view/main_pages/setting.dart';
import 'package:chat_me/view/main_pages/vedioCall.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../controller/authenticate_provider.dart';
import '../../controller/localizations_provider.dart';
import '../../controller/theme_provider.dart';
import '../../model/theme.dart';
import '../authenticate_pages/login_screen.dart';
import '../authenticate_pages/personal_data_entry_screen.dart';
import '../secondry_pages/messages.dart';
import '../secondry_pages/user_profile.dart';
import 'chat.dart';
import 'home.dart';
import 'my_profile.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
     debugShowCheckedModeBanner: false ,
      home:  MyApplication(),
    );
  }
}

class MyApplication extends StatefulWidget {
  const MyApplication({Key? key}) : super(key: key);

  @override
  State<MyApplication> createState() => _MyAppState();
}

class _MyAppState extends State<MyApplication> with WidgetsBindingObserver {
  int pageIndex = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () async {
      bool dataExist =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .isDataExist();
      if (FirebaseAuth.instance.currentUser != null && dataExist) {
        FirebaseFirestore.instance
            .doc('users/${FirebaseAuth.instance.currentUser!.uid}')
            .update({'activity': 'Active'});
      }
    });
    getPermissions();
    getInitialNotification();
    FirebaseMessaging.onMessage.listen((message) async {
      Map<String, dynamic> currentUserData = (await FirebaseFirestore.instance
              .collection('users/')
              .get())
          .docs
          .firstWhere(
              (element) => element.id == FirebaseAuth.instance.currentUser!.uid)
          .data();
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(
                message.notification!.title!,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.notification!.body!),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushNamed(MessagesScreen.routeName, arguments: {
                        'userData': Users(
                          message.data['id'],
                          message.data['activity'],
                          message.data['firsName'],
                          message.data['lastName'],
                          message.data['personalImage'],
                          message.data['phoneNumber'],
                          message.data['status'],
                        ),
                        'currentUserData': Users(
                          currentUserData['id'],
                          currentUserData['activity'],
                          currentUserData['firsName'],
                          currentUserData['lastName'],
                          currentUserData['personalImage'],
                          currentUserData['phoneNumber'],
                          currentUserData['status'],
                        ),
                      });
                    },
                    child: const Text('Go'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const VideoCall()));
      Map<String, dynamic> currentUserData = (await FirebaseFirestore.instance
              .collection('users/')
              .get())
          .docs
          .firstWhere(
              (element) => element.id == FirebaseAuth.instance.currentUser!.uid)
          .data();
      Navigator.pushNamed(context, MessagesScreen.routeName, arguments: {
        'userData': Users(
          message.data['id'],
          message.data['activity'],
          message.data['firsName'],
          message.data['lastName'],
          message.data['personalImage'],
          message.data['phoneNumber'],
          message.data['status'],
        ),
        'currentUserData': Users(
          currentUserData['id'],
          currentUserData['activity'],
          currentUserData['firsName'],
          currentUserData['lastName'],
          currentUserData['personalImage'],
          currentUserData['phoneNumber'],
          currentUserData['status'],
        ),
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    bool dataExist =
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .isDataExist();
    if (!dataExist) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .doc('users/${FirebaseAuth.instance.currentUser!.uid}')
          .update({'activity': 'Active'});
    } else if (state == AppLifecycleState.inactive) {
      FirebaseFirestore.instance
          .doc('users/${FirebaseAuth.instance.currentUser!.uid}')
          .update({'activity': 'Inactive'});
    } else if (state == AppLifecycleState.paused) {
      FirebaseFirestore.instance
          .doc('users/${FirebaseAuth.instance.currentUser!.uid}')
          .update({'activity': 'Inactive'});
    }
    super.didChangeAppLifecycleState(state);
  }

  getPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  getInitialNotification() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      Map<String, dynamic> currentUserData = (await FirebaseFirestore.instance
              .collection('users/')
              .get())
          .docs
          .firstWhere(
              (element) => element.id == FirebaseAuth.instance.currentUser!.uid)
          .data();
      Navigator.pushNamed(context, MessagesScreen.routeName, arguments: {
        'userData': Users(
          message.data['id'],
          message.data['activity'],
          message.data['firsName'],
          message.data['lastName'],
          message.data['personalImage'],
          message.data['phoneNumber'],
          message.data['status'],
        ),
        'currentUserData': Users(
          currentUserData['id'],
          currentUserData['activity'],
          currentUserData['firsName'],
          currentUserData['lastName'],
          currentUserData['personalImage'],
          currentUserData['phoneNumber'],
          currentUserData['status'],
        ),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeProvider.currentThemeMode,
      darkTheme: MyTheme.darkTheme,
      theme: MyTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: LocalizationsProvider.currentLocale,
      routes: {
        MessagesScreen.routeName: (_) => const MessagesScreen(),
        UserProfile.userProfileRoutName: (_) => UserProfile(),
      },
      home : FutureBuilder(
        future: Provider.of<AuthenticationProvider>(context).isDataExist(),
        builder: (context, snapShot) => Consumer<AuthenticationProvider>(
          builder: (context, value, _) => Scaffold(
            bottomNavigationBar: (snapShot.data == true)
                ? CurvedNavigationBar(
                    height: 60,
                    backgroundColor: Colors.transparent,
                    buttonBackgroundColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkMode()
                            ? Colors.black
                            : const Color(0xFF128C7E),
                    color: Provider.of<ThemeProvider>(context, listen: false)
                            .isDarkMode()
                        ? Colors.black45
                        : Theme.of(context)
                            .primaryColor
                            .withGreen(255)
                            .withOpacity(.8),
                    index: pageIndex,
                    animationDuration: const Duration(milliseconds: 300),
                    onTap: (index) => setState(() {
                      pageIndex = index;
                    }),
                    items: const [
                      Icon(Icons.person),
                      Icon(Icons.home),
                      Icon(Icons.chat),
                      Icon(Icons.settings),
                    ],
                  )
                : null,
            body: (FirebaseAuth.instance.currentUser == null)
                ? const AuthenticateScreen()
                : (snapShot.data == true)
                    ? (pageIndex == 0)
                        ? Hero(tag: 'mainScreens', child: MyProfile())
                        : (pageIndex == 1)
                            ? const Hero(tag: 'mainScreens', child: HomePage())
                            : (pageIndex == 2)
                                ? const Hero(
                                    tag: 'mainScreens', child: ChatsPage())
                                : Hero(tag: 'mainScreens', child: SettingPage())
                    : PersonalDataEntryScreen(),
          ),
        ),
      ),
    );
  }
}
