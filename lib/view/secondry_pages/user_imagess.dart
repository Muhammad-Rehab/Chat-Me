import 'package:chat_me/view/main_pages/my_profile.dart';
import 'package:chat_me/view/secondry_pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserImages extends StatefulWidget {
  static String routName = 'user_images';
  static bool isMyProfile = true;

  @override
  State<UserImages> createState() => _UserImagesState();
}

class _UserImagesState extends State<UserImages> {
  PageController controller = PageController(
    viewportFraction: .80,
  );
  List<String> imagesUrlList = [];
  int imageIndex = 0;

  @override
  void initState() {
    if (UserImages.isMyProfile) {
      imagesUrlList = MyProfile.imagesUrlList.keys.toList();
    } else {
      imagesUrlList = UserProfile.imagesUrlList.keys.toList();
    }
    super.initState();
  }

  @override
  void dispose() {
    imagesUrlList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).backgroundColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: (imagesUrlList.isEmpty)
          ? Center(
              child: Text(AppLocalizations.of(context)!.userImagesLoading),
            )
          : PageView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: imagesUrlList.length,
              controller: controller,
              onPageChanged: (value) {
                setState(() {
                  imageIndex = value;
                });
              },
              itemBuilder: (_, index) => AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutQuint,
                width: double.infinity,
                height: double.infinity,
                margin: EdgeInsets.only(
                    top: (index == imageIndex) ? 40 : 200,
                    bottom: 50,
                    right: 30),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black87,
                          blurRadius: (index == imageIndex) ? 30 : 0,
                          offset: (index == imageIndex)
                              ? const Offset(0, 20)
                              : const Offset(0, 0))
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/images/avatar.jpg'),
                    image: NetworkImage(imagesUrlList[index]),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
    );
  }
}
