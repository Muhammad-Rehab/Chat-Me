
import 'package:chat_me/controller/myProfile_provider.dart';
import 'package:chat_me/view/secondry_pages/user_imagess.dart';
import 'package:chat_me/controller/theme_provider.dart';
import '../../controller/chat_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MyProfile extends StatefulWidget {
  static Map<String, String> imagesUrlList = {};

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

  getSlideDialog(BuildContext context) {
    showSlideDialog(
      backgroundColor: Theme.of(context).splashColor,
      context: context,
      child: Expanded(
        child: SingleChildScrollView(
          child: Form(
            key: Provider.of<MyProfileProvider>(context,listen: false).formKey,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.myProfileEditData,
                  style: Theme.of(context).textTheme.headline1,
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.personalEntryScreenFirstName,
                      labelStyle: const  TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    initialValue: Provider.of<ChatProvider>(context,listen: false).currentUserData!.firstName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.personalEntryScreenFirstNameError;
                      } else if (value.length <= 2) {
                        return AppLocalizations.of(context)!.myProfileFirstNameError1;
                      } else if (value.length >= 20) {
                        return AppLocalizations.of(context)!.myProfileFirstNameError2;
                      }
                    },
                    onSaved: (value) {
                      Provider.of<MyProfileProvider>(context,listen: false).editingUserData['firsName'] = value!;
                    },
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.personalEntryScreenLastName,
                      labelStyle: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    initialValue:
                    Provider.of<ChatProvider>(context,listen: false).currentUserData!.lastName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.personalEntryScreenLastNameError;
                      } else if (value.length <= 2) {
                        return AppLocalizations.of(context)!.myProfileLastNameError1;
                      } else if (value.length >= 20) {
                        return AppLocalizations.of(context)!.myProfileLastNameError2;
                      }
                    },
                    onSaved: (value) {
                      Provider.of<MyProfileProvider>(context,listen: false).editingUserData['lastName'] = value!;
                    },
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    maxLength: 100,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.personalEntryScreenStatus,
                      labelStyle:const  TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    initialValue: Provider.of<ChatProvider>(context,listen: false).currentUserData!.status,
                    onSaved: (value) {
                      Provider.of<MyProfileProvider>(context,listen: false).editingUserData['status'] = value!;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<MyProfileProvider>(context,listen: false).updateData(context);
                    Navigator.of(context).pop();
                     Provider.of<ChatProvider>(context,listen: false).getHomeData();
                     Provider.of<ChatProvider>(context,listen: false).getHomeData();
                  },
                  child:  Text(AppLocalizations.of(context)!.myProfileUpdateData),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      (await FirebaseStorage.instance
              .ref('images/${FirebaseAuth.instance.currentUser!.phoneNumber}/')
              .listAll())
          .items
          .forEach((element) {
        element.getDownloadURL().then((value) {
          MyProfile.imagesUrlList.putIfAbsent(value, () => '');
        });
      });
    });
    Provider.of<ChatProvider>(context,listen: false).getHomeData();
    UserImages.isMyProfile = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.myProfileTitle),
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
                      (Provider.of<ChatProvider>(context,listen: false).currentUserData == null)
                          ? null
                          : NetworkImage(
                          Provider.of<ChatProvider>(context).currentUserData!.personalImage),
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
                  '${Provider.of<ChatProvider>(context).currentUserData!.firstName} ${Provider.of<ChatProvider>(context).currentUserData!.lastName}',
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.only(
                  top: 20, left: 25, right: 25, bottom: 8),
              child: Text(
                Provider.of<ChatProvider>(context).currentUserData!.status,
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
                title: Text(Provider.of<ChatProvider>(context).currentUserData!.phoneNumber),
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
                      getSlideDialog(context);
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 26,
                    ),
                    color: Provider.of<ThemeProvider>(context).isDarkMode()
                        ? null
                        : Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
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
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: SizedBox(
                            height: 100,
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () async{
                                    await Provider.of<MyProfileProvider>(context,listen: false).pickImage(ImageSource.camera,context);
                                    Provider.of<ChatProvider>(context,listen: false).getHomeData();
                                    Provider.of<ChatProvider>(context,listen: false).getHomeData();
                                  },
                                  child:  Text(AppLocalizations.of(context)!.personalEntryScreenCamera),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await Provider.of<MyProfileProvider>(context,listen: false).pickImage(ImageSource.gallery,context);
                                    Provider.of<ChatProvider>(context,listen: false).getHomeData();
                                    Provider.of<ChatProvider>(context,listen: false).getHomeData();
                                  },
                                  child: Text(AppLocalizations.of(context)!.personalEntryScreenGallery),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_a_photo_outlined,
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
