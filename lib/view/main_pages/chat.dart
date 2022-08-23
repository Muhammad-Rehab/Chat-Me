import 'package:chat_me/model/messages.dart';
import 'package:chat_me/view/main_pages/home.dart';
import 'package:chat_me/view/secondry_pages/messages.dart';
import 'package:chat_me/controller/chat_provider.dart';
import 'package:chat_me/controller/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);
  static const statusRoute = '/chats';

  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {
  bool isLandScape = false;

  double paddingTop = 0;

  @override
  Widget build(BuildContext context) {
    paddingTop = MediaQuery.of(context).padding.top;
    isLandScape = MediaQuery.of(context).orientation == Orientation.landscape;
    AppBar appBar = AppBar(
      elevation: 0,
      title: Text(AppLocalizations.of(context)!.chatPageTitle),
      actions: [
        IconButton(
          onPressed: () async {
            showSearch(
              context: context,
              delegate: Search(
                  Provider.of<ChatProvider>(context, listen: false).data),
            );
          },
          icon: const Icon(
            Icons.search,
          ),
        )
      ],
    );
    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode()
          ? const Color(0xFFA12568).withRed(100)
          : const Color(0xFF075E54),
      appBar: appBar,
      body: Column(
        children: [
          Container(
            height: isLandScape ? 0 : 100,
            margin: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Provider.of<ChatProvider>(
                context,
              ).data.length,
              itemBuilder: (ctx, index) => InkWell(
                onTap: () {
                  Navigator.pushNamed(context, MessagesScreen.routeName,
                      arguments: {
                        'userData':
                            Provider.of<ChatProvider>(context, listen: false)
                                .data[index],
                        'currentUserData':
                            Provider.of<ChatProvider>(context, listen: false)
                                .currentUserData
                      });
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(29),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child: FadeInImage(
                            placeholder: const AssetImage(
                              'assets/images/avatar.jpg',
                            ),
                            image: NetworkImage(
                                Provider.of<ChatProvider>(context)
                                    .data[index]
                                    .personalImage),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        Provider.of<ChatProvider>(context, listen: false)
                            .data[index]
                            .firstName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).isDarkMode()
                      ? const Color(0xFF2A0944)
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: FutureBuilder<List<Messages>>(
                future: Provider.of<ChatProvider>(context, listen: true)
                    .getChatData(),
                builder: (context, snapShot) => (!snapShot.hasData)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : (snapShot.data == null || snapShot.data!.isEmpty)
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.chatPageError),
                          )
                        : ListView.builder(
                            itemCount: snapShot.data!.length,
                            itemBuilder: (_, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, MessagesScreen.routeName,
                                      arguments: {
                                        'userData': (snapShot.data![index]
                                                    .sentTo.phoneNumber ==
                                                FirebaseAuth.instance
                                                    .currentUser!.phoneNumber)
                                            ? snapShot.data![index].sentFrom
                                            : snapShot.data![index].sentTo,
                                        'currentUserData': (snapShot
                                                    .data![index]
                                                    .sentTo
                                                    .phoneNumber ==
                                                FirebaseAuth.instance
                                                    .currentUser!.phoneNumber)
                                            ? snapShot.data![index].sentTo
                                            : snapShot.data![index].sentFrom,
                                      });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(29),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(29),
                                          child: FadeInImage(
                                            placeholder: const AssetImage(
                                              'assets/images/avatar.jpg',
                                            ),
                                            image: NetworkImage((snapShot
                                                        .data![index]
                                                        .sentTo
                                                        .phoneNumber ==
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .phoneNumber)
                                                ? snapShot.data![index].sentFrom
                                                    .personalImage
                                                : snapShot.data![index].sentTo
                                                    .personalImage),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (snapShot.data![index].sentTo
                                                          .phoneNumber ==
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .phoneNumber)
                                                  ? '${snapShot.data![index].sentFrom.firstName} ${snapShot.data![index].sentFrom.lastName}'
                                                  : '${snapShot.data![index].sentTo.firstName} ${snapShot.data![index].sentTo.lastName}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2,
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              (snapShot.data![index]
                                                          .messageType ==
                                                      'String')
                                                  ? snapShot
                                                      .data![index].message
                                                  : p.basename(snapShot
                                                      .data![index].message),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Column(
                                        children: [
                                          Text(
                                            Provider.of<ChatProvider>(context)
                                                .getDate(
                                                    snapShot.data![index].time
                                                        .toDate(),
                                                    context),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          FutureBuilder<String>(
                                            future: (snapShot.data![index]
                                                        .sentTo.phoneNumber ==
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .phoneNumber)
                                                ? Provider.of<ChatProvider>(
                                                        context)
                                                    .getUserActivity(snapShot
                                                        .data![index]
                                                        .sentFrom
                                                        .id)
                                                : Provider.of<ChatProvider>(
                                                        context)
                                                    .getUserActivity(snapShot
                                                        .data![index]
                                                        .sentTo
                                                        .id),
                                            builder: (_, snapShot2) => Chip(
                                              label: Text((snapShot2.data ==
                                                          'Active' ||
                                                      snapShot2.data ==
                                                          'Connected')
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .userActivityActive
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .userActivityInActive),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
