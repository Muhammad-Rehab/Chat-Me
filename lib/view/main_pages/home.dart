import 'package:chat_me/model/user.dart';
import 'package:chat_me/view/secondry_pages/messages.dart';
import 'package:chat_me/view/secondry_pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../controller/chat_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  late AppBar appBar  ;
  bool isLandScape = false ;
  @override
  Widget build(BuildContext context) {
    appBar = AppBar(
        title: Text(AppLocalizations.of(context)!.homePageTitle),
    actions: [
    IconButton(
    onPressed: () {
    showSearch(
    context: context,
    delegate: Search(Provider.of<ChatProvider>(context,listen: false).data),
    );
    },
    icon: const Icon(Icons.search),
    )
    ],
    ) ;
    isLandScape = MediaQuery.of(context).orientation == Orientation.landscape ;
    return Scaffold(
      appBar: appBar ,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(0),
            height: isLandScape?0: (MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top - appBar.preferredSize.height) * .3,
            width: double.infinity,
            child: Image.asset(
              'assets/images/chat.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: Provider.of<ChatProvider>(context,listen: false).getHomeData(),
              builder: (context, snapShot) => (snapShot.connectionState ==
                      ConnectionState.waiting)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : (snapShot.hasError)
                      ? Center(
                          child: Text(AppLocalizations.of(context)!
                              .failedAccessingDataHomePage),
                        )
                      : (snapShot.data == null)
                          ? Text(
                              AppLocalizations.of(context)!.noDataFoundHomePage)
                          : Container(
                              margin: const EdgeInsets.all(10),
                              child: ListView.builder(
                                itemCount: Provider.of<ChatProvider>(context).data.length,
                                itemBuilder: (context, index) => ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                          'assets/images/avatar.jpg',
                                        ),
                                        image: NetworkImage(
                                            Provider.of<ChatProvider>(context).data[index].personalImage),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    '${Provider.of<ChatProvider>(context).data[index].firstName} ${Provider.of<ChatProvider>(context).data[index].lastName}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text(Provider.of<ChatProvider>(context).data[index].phoneNumber),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, MessagesScreen.routeName,
                                        arguments: {
                                          'userData':Provider.of<ChatProvider>(context,listen: false).data[index],
                                          'currentUserData': Provider.of<ChatProvider>(context,listen: false).currentUserData
                                        });
                                  },
                                  trailing: IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context,
                                          UserProfile.userProfileRoutName,
                                          arguments: {
                                            'userProfileData': Provider.of<ChatProvider>(context,listen: false).data[index]
                                          });
                                    },
                                    icon: const Icon(Icons.person),
                                  ),
                                ),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

class Search extends SearchDelegate<dynamic> {
  List<Users> data = [];

  Search(List<Users>? externalData) {
    if (externalData != null) {
      data = externalData;
    }
  }

  String? selectedText;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('$selectedText'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Users> suggestionList = [];
    (query.isEmpty)
        ? suggestionList = Provider.of<ChatProvider>(context,listen: false).currentList
        : suggestionList.addAll(data.where((element) =>
            "${element.firstName}${element.lastName}"
                .toLowerCase()
                .contains(query.toLowerCase())));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          '${suggestionList[index].firstName} ${suggestionList[index].lastName}',
          textAlign: TextAlign.start,
        ),
        onTap: () {
          Provider.of<ChatProvider>(context,listen: false).currentList.add(suggestionList[index]);
          selectedText = "${suggestionList[index].firstName} ${suggestionList[index].lastName}}";
          Navigator.pushNamed(context, MessagesScreen.routeName, arguments: {
            'userData': suggestionList[index],
            'currentUserData': Provider.of<ChatProvider>(context,listen: false).currentUserData
          });
        },
      ),
    );
  }
}
