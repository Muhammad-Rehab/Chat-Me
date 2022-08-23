import 'package:chat_me/controller/chat_provider.dart';
import 'package:chat_me/view/secondry_pages/messages.dart';
import 'package:chat_me/view/secondry_pages/user_imagess.dart';
import 'package:chat_me/controller/theme_provider.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfile extends StatefulWidget {
  static String userProfileRoutName = 'user_profile';

  static Map<String, String> imagesUrlList = {};

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var userProfileData;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      (await FirebaseStorage.instance
              .ref('images/${userProfileData['userProfileData'].phoneNumber}/')
              .listAll())
          .items
          .forEach((element) {
        element.getDownloadURL().then((value) {
          UserProfile.imagesUrlList.putIfAbsent(value, () => '');
        });
      });
      UserImages.isMyProfile = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    UserProfile.imagesUrlList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProfileData = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
            future: Provider.of<ChatProvider>(context)
                .getUserActivity(userProfileData['userProfileData'].id),
            builder: (_, snapShot) => Text((!snapShot.hasData)
                ? ''
                : (snapShot.data == 'Active' || snapShot.data == 'Connected')
                    ? AppLocalizations.of(context)!.userActivityActive
                    : AppLocalizations.of(context)!.userActivityInActive)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              alignment: Alignment.topCenter,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                        child: UserImages(),
                        type: PageTransitionType.scale,
                        alignment: Alignment.center,
                      ));
                },
                child: CircleAvatar(
                  backgroundImage: const AssetImage('assets/images/avatar.jpg'),
                  foregroundImage:
                      (userProfileData['userProfileData'].personalImage == null)
                          ? null
                          : NetworkImage(
                              userProfileData['userProfileData'].personalImage),
                  radius: 100,
                ),
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  '${userProfileData['userProfileData'].firstName} ${userProfileData['userProfileData'].lastName}',
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.only(
                  top: 20, left: 25, right: 25, bottom: 8),
              child: Text(
                userProfileData['userProfileData'].status,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.only(
                left: 14,
              ),
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: Text(userProfileData['userProfileData'].phoneNumber),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 20),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Provider.of<ThemeProvider>(context).isDarkMode()
                          ? Colors.transparent
                          : Theme.of(context).appBarTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, MessagesScreen.routeName,
                          arguments: {
                            'userData': userProfileData['userProfileData'],
                            'currentUserData': Provider.of<ChatProvider>(
                                    context,
                                    listen: false)
                                .currentUserData,
                          });
                    },
                    icon: const Icon(
                      Icons.chat,
                      size: 26,
                    ),
                    color: Provider.of<ThemeProvider>(context).isDarkMode()
                        ? null
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
