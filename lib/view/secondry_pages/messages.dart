import 'dart:async';
import 'dart:io';

import 'package:chat_me/controller/chat_provider.dart';
import 'package:chat_me/controller/message_provider.dart';
import 'package:chat_me/view/main_pages/vedioCall.dart';
import 'package:chat_me/view/secondry_pages/user_profile.dart';
import 'package:chat_me/controller/audio_provider.dart';
import '../../model/theme.dart';
import '../../model/user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../../controller/theme_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:toast/toast.dart';



class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);
  static const routeName = '/messagesScreen';

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {

  bool isLandScape = false ;
  @override
  void initState() {
    Provider.of<Audio>(context, listen: false).initPlayer();
    Provider.of<MessageProvider>(context,listen: false).controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
   void dispose() {
    try{
      Provider.of<MessageProvider>(context,listen: false).textController.dispose();
      Provider.of<MessageProvider>(context,listen: false).showDownloadIndicator = false;
      Provider.of<MessageProvider>(context,listen: false).controller!.dispose();
    }catch(e){
      print(e.toString());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<MessageProvider>(context,listen: false).arguments = ModalRoute.of(context)!.settings.arguments;
    Provider.of<MessageProvider>(context,listen: false).currentUserData = Provider.of<MessageProvider>(context,listen: false).arguments['currentUserData'];
    ToastContext().init(context);
    isLandScape = MediaQuery.of(context).orientation == Orientation.landscape ;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeProvider.currentThemeMode,
      darkTheme: MyTheme.darkTheme,
      theme: MyTheme.lightTheme,
      home: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              Navigator.pushNamed(context, UserProfile.userProfileRoutName,
                  arguments: {'userProfileData': Provider.of<MessageProvider>(context,listen: false).arguments['userData']});
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                  '${Provider.of<MessageProvider>(context).arguments['userData'].firstName}'
                      ' ${Provider.of<MessageProvider>(context).arguments['userData'].lastName}'),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              if (Provider.of<Audio>(context, listen: false)
                  .recordingState
                  .isNotEmpty) {
                Provider.of<Audio>(context, listen: false).disposeRecorder();
                Provider.of<Audio>(context, listen: false).disposePlayer();
              }
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_)=> const VideoCall(),
                ));
              },
              icon: const Icon(Icons.video_call_sharp),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection(
                      'chats/${FirebaseAuth.instance.currentUser!.phoneNumber}/'
                      '${Provider.of<MessageProvider>(context,listen: false).arguments['userData'].phoneNumber}',
                    )
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapShot) => ListView.builder(
                  reverse: true,
                  itemCount:
                      (snapShot.data == null) ? 0 : snapShot.data!.docs.length,
                  itemBuilder: (context, index) => messageBubble(
                      snapShot.data!.docs[index].data(),
                      snapShot.data!.docs[index]['sentTo']['phoneNumber'],
                      Provider.of<MessageProvider>(context,listen: false).currentUserData!,
                      index),
                ),
              ),
            ),
            newMessage(),
            Offstage(
              offstage: !Provider.of<MessageProvider>(context).showEmoji,
              child: SizedBox(
                height: isLandScape?150:250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      Provider.of<MessageProvider>(context,listen: false).textController
                        ..text += emoji.emoji
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: Provider.of<MessageProvider>(context,listen: false).textController.text.length));
                    });
                  },
                  onBackspacePressed: () {
                    setState(() {
                      Provider.of<MessageProvider>(context,listen: false).textController
                        ..text = Provider.of<MessageProvider>(context,listen: false).textController.text.characters
                            .skipLast(1)
                            .toString()
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset:Provider.of<MessageProvider>(context,listen: false).textController.text.length));
                    });
                  },
                  config: Config(
                      columns: 7,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      initCategory: Category.RECENT,
                      bgColor: const Color(0xFFF2F2F2),
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      progressIndicatorColor: Colors.blue,
                      backspaceColor: Colors.blue,
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      showRecentsTab: true,
                      recentsLimit: 28,
                      noRecentsText: "No Recents",
                      noRecentsStyle:
                          const TextStyle(fontSize: 20, color: Colors.black26),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  newMessage() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (Provider.of<MessageProvider>(context).isFileUploading)
            Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * .82,
              height: 50,
              child: const Text(
                'Uploading File....',
                style: TextStyle(fontSize: 20),
              ),
            ),
          if (Provider.of<MessageProvider>(context).isFilePicked)
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              width: MediaQuery.of(context).size.width * .82,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Provider.of<MessageProvider>(context).result!.files.first.name,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              SizedBox(
                width:isLandScape?  MediaQuery.of(context).size.width * .9
                    : MediaQuery.of(context).size.width * .82,
                child: (Provider.of<Audio>(context).recordingState == 'isRecording' ||
                        Provider.of<Audio>(context).recordingState == 'isPaused')
                    ? Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(Provider.of<Audio>(context).audioLength / 60).floor()} : ${Provider.of<Audio>(context).audioLength % 60}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            InkWell(
                              onTap: () {
                                if (Provider.of<Audio>(context, listen: false)
                                        .recordingState ==
                                    'isPaused') {
                                  Provider.of<MessageProvider>(context,listen: false).controller!.reverse();
                                } else {
                                  Provider.of<MessageProvider>(context,listen: false).controller!.forward();
                                }
                                Provider.of<Audio>(context, listen: false)
                                    .toggleRecording();
                              },
                              child: AnimatedIcon(
                                icon: AnimatedIcons.pause_play,
                                progress: Provider.of<MessageProvider>(context,listen: false).controller!,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Card(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: Provider.of<MessageProvider>(context,listen: false).textController,
                          enabled: Provider.of<MessageProvider>(context).textFieldEnabled && !isLandScape ,
                          onChanged: (value) {
                            setState(() {
                              Provider.of<MessageProvider>(context,listen: false).currentMessage = value;
                            });
                          },
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  Provider.of<MessageProvider>(context,listen: false).showEmoji = !Provider.of<MessageProvider>(context,listen: false).showEmoji;
                                });
                              },
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.black,
                              ),
                            ),
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Provider.of<MessageProvider>(context,listen: false).sendFile();
                                  },
                                  icon: const Icon(Icons.attach_file,
                                      color: Colors.black),
                                ),
                                if (Provider.of<MessageProvider>(context).currentMessage == '')
                                  IconButton(
                                    onPressed: () async {
                                      await Provider.of<Audio>(context,
                                              listen: false)
                                          .initRecorder();
                                      if (Provider.of<Audio>(context,
                                                      listen: false)
                                                  .recordingState ==
                                              'isStopped' ||
                                          Provider.of<Audio>(context,
                                                      listen: false)
                                                  .recordingState ==
                                              '') {
                                        await Provider.of<Audio>(context,
                                                listen: false)
                                            .toggleRecording();
                                      }
                                    },
                                    icon: const Icon(Icons.mic,
                                        color: Colors.black),
                                  ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            isCollapsed: !Provider.of<ThemeProvider>(context)
                                .isDarkMode(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            hintText: AppLocalizations.of(context)!
                                .messagesPageSendMessage,
                          ),
                        ),
                      ),
              ),
              IconButton(
                onPressed: (Provider.of<MessageProvider>(context).textController.text.isEmpty &&
                        !Provider.of<MessageProvider>(context).isFilePicked &&
                        Provider.of<Audio>(context).recordingPath.isEmpty)
                    ? null
                    : () {
                  Provider.of<MessageProvider>(context,listen: false).sendMessage(context);
                      },
                icon: const Icon(Icons.send),
                color: Theme.of(context).backgroundColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  messageBubble(Map<String, dynamic> message, String sentTo,
      Users currentUserData, int index) {
    bool isMe = !(FirebaseAuth.instance.currentUser!.phoneNumber == sentTo);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Dismissible(
        direction:
            isMe ? DismissDirection.endToStart : DismissDirection.startToEnd,
        background: const Icon(Icons.delete),
        confirmDismiss: (DismissDirection direction) {
          return showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: SizedBox(
                      height: 150,
                      child: Column(
                        children: [
                          Text(AppLocalizations.of(context)!
                              .messagesPageDeleteMessage),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Provider.of<MessageProvider>(context,listen: false).deleteMessage(message);
                            },
                            child: Text(
                                AppLocalizations.of(context)!.messagesPageOkay),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)!
                                .messagesPageDeleteUndo),
                          ),
                        ],
                      ),
                    ),
                  ));
        },
        key: UniqueKey(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              (isMe) ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (isMe)
              InkWell(
                onTap: () {},
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: const AssetImage(
                    'assets/images/avatar.jpg',
                  ),
                  foregroundImage: NetworkImage(currentUserData.personalImage),
                ),
              ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 10, top: 3),
                decoration: BoxDecoration(
                  color: (isMe)
                      ? Theme.of(context).splashColor
                      : Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: (isMe)
                        ? const Radius.circular(0)
                        : const Radius.circular(10),
                    topRight: (isMe)
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomLeft: const Radius.circular(10),
                    bottomRight: const Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: (isMe)
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      (!isMe)
                          ? '${Provider.of<MessageProvider>(context).arguments['userData'].firstName}'
                          ' ${Provider.of<MessageProvider>(context).arguments['userData'].lastName}'
                          : '${currentUserData.firstName} ${currentUserData.lastName}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    if (message['messageType'] == 'String')
                      Text(
                        message['message'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    if ((message['messageType'] == 'File Saved' ||
                            message['messageType'] == 'File Saved 2') &&
                        isMe)
                      TextButton(
                        onPressed: () async {
                          OpenFile.open(message['message']);
                        },
                        child: Text(
                          p.basename('${message['message']}'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (message['messageType'] == 'File Saved' && !isMe)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              p.basename(message['message']),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  Provider.of<MessageProvider>(context,listen: false).showDownloadIndicator = true;
                                });
                                Provider.of<MessageProvider>(context,listen: false).downloadFile(message, sentTo, currentUserData,context);
                              },
                              icon:Provider.of<MessageProvider>(context,). showDownloadIndicator
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.download_rounded),
                            ),
                          )
                        ],
                      ),
                    if (message['messageType'] == 'File Saved 2' && !isMe)
                      TextButton(
                        onPressed: () async {
                          OpenFile.open(message['receiverFilePath']);
                        },
                        child: Text(
                          p.basename('${message['receiverFilePath']}'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    if ((message['messageType'] == 'Record Saved' ||
                            message['messageType'] == 'Record Saved 2') &&
                        isMe)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Slider(
                            value: (Provider.of<MessageProvider>(context,listen: false).sliderIndex == index) ?
                            Provider.of<MessageProvider>(context,listen: false).sliderValue : 0,
                            min: 0,
                            max: (message['recordLength']).toDouble(),
                            divisions: (message['recordLength']),
                            onChanged: (val) {},
                          ),
                          InkWell(
                            onTap: () async {
                              await Provider.of<Audio>(context, listen: false)
                                  .togglePlayer(message['message'], () {});
                              if (!(Provider.of<Audio>(context, listen: false)
                                  .isPlaying)) {
                                setState(() {
                                  Provider.of<MessageProvider>(context,listen: false).sliderIndex = -1;
                                  Provider.of<MessageProvider>(context,listen: false).sliderValue = 0;
                                  Provider.of<MessageProvider>(context,listen: false).controller!.reset();
                                  Provider.of<MessageProvider>(context,listen: false).timer.cancel();
                                });
                                return;
                              }
                              setState(() {
                                Provider.of<MessageProvider>(context,listen: false).sliderIndex = index;
                              });
                              Provider.of<MessageProvider>(context,listen: false).controller!.forward();
                              Provider.of<MessageProvider>(context,listen: false).timer = Timer.periodic(
                                  const Duration(seconds: 1), (timer) {
                                setState(() {
                                  if (Provider.of<MessageProvider>(context,listen: false).sliderValue ==
                                      message['recordLength'].toDouble()) {
                                    Provider.of<MessageProvider>(context,listen: false).sliderIndex = -1;
                                    Provider.of<MessageProvider>(context,listen: false).sliderValue = 0;
                                    Provider.of<MessageProvider>(context,listen: false).controller!.reset();
                                    Provider.of<MessageProvider>(context,listen: false).timer.cancel();
                                    return;
                                  }
                                  Provider.of<MessageProvider>(context,listen: false).sliderValue++;
                                });
                              });
                            },
                            child: (Provider.of<MessageProvider>(context).sliderIndex == index)
                                ? AnimatedIcon(
                                    progress: Provider.of<MessageProvider>(context,listen: false).controller!,
                                    icon: AnimatedIcons.play_pause,
                                  )
                                : const Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    if (message['messageType'] == 'Record Saved' && !isMe)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Slider(
                            value: 0,
                            min: 0,
                            max: 0,
                            onChanged: (val) {},
                          ),
                          IconButton(
                            onPressed: () {
                              Provider.of<Audio>(context, listen: false)
                                  .downloadRecord(
                                      message, sentTo, currentUserData);
                            },
                            icon: const Icon(Icons.download_rounded),
                          ),
                        ],
                      ),
                    if (message['messageType'] == 'Record Saved 2' && !isMe)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Slider(
                            value: (Provider.of<MessageProvider>(context,listen: false).sliderIndex == index) ?
                            Provider.of<MessageProvider>(context,listen: false).sliderValue : 0,
                            min: 0,
                            max: (message['recordLength']).toDouble(),
                            divisions: (message['recordLength']),
                            onChanged: (val) {},
                          ),
                          InkWell(
                            onTap: () async {
                              await Provider.of<Audio>(context, listen: false)
                                  .togglePlayer(
                                      message['receiverFilePath'], () {});
                              if (!(Provider.of<Audio>(context, listen: false)
                                  .isPlaying)) {
                                setState(() {
                                  Provider.of<MessageProvider>(context,listen: false).sliderIndex = -1;
                                  Provider.of<MessageProvider>(context,listen: false).sliderValue = 0;
                                  Provider.of<MessageProvider>(context,listen: false).controller!.reset();
                                  Provider.of<MessageProvider>(context,listen: false).timer.cancel();
                                });
                                return;
                              }
                              setState(() {
                                Provider.of<MessageProvider>(context,listen: false).sliderIndex = index;
                              });
                              Provider.of<MessageProvider>(context,listen: false).controller!.forward();
                              Provider.of<MessageProvider>(context,listen: false).timer = Timer.periodic(
                                  const Duration(seconds: 1), (timer) {
                                setState(() {
                                  if (Provider.of<MessageProvider>(context,listen: false).sliderValue ==
                                      message['recordLength'].toDouble()) {
                                    Provider.of<MessageProvider>(context,listen: false).sliderIndex = -1;
                                    Provider.of<MessageProvider>(context,listen: false). sliderValue = 0;
                                    Provider.of<MessageProvider>(context,listen: false).controller!.reset();
                                    Provider.of<MessageProvider>(context,listen: false).timer.cancel();
                                    return;
                                  }
                                  Provider.of<MessageProvider>(context,listen: false).sliderValue++;
                                });
                              });
                            },
                            child: (Provider.of<MessageProvider>(context).sliderIndex == index)
                                ? AnimatedIcon(
                                    progress: Provider.of<MessageProvider>(context,listen: false).controller!,
                                    icon: AnimatedIcons.play_pause,
                                  )
                                : const Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment:
                          (message['messageType'] == 'Record Saved' ||
                                  message['messageType'] == 'Record Saved 2')
                              ? MainAxisAlignment.spaceAround
                              : MainAxisAlignment.start,
                      children: [
                        Text(
                          Provider.of<ChatProvider>(context).getDate(DateTime.fromMicrosecondsSinceEpoch(
                              message['time'].microsecondsSinceEpoch),context),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        if (message['messageType'] == 'Record Saved' ||
                            message['messageType'] == 'Record Saved 2')
                          Text(
                            '${(message['recordLength'] / 60).floor()} : ${message['recordLength'] % 60}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            if (!isMe)
              InkWell(
                onTap: () {},
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: const AssetImage(
                    'assets/images/avatar.jpg',
                  ),
                  foregroundImage:
                      NetworkImage(Provider.of<MessageProvider>(context).arguments['userData'].personalImage),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
