import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/edit_profile/edit_profile_screen.dart';
import 'package:hi/screens/home/tabs/requests_tab/requests_tab.dart';
import 'package:hi/screens/home/tabs/chat_tab/chat_tab.dart';
import 'package:hi/screens/home/tabs/friends_tab/friends_tab.dart';
import 'package:hi/screens/welcome_screen.dart';
import 'package:hi/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    FirebaseService.setCurrentUserOnline(state: true);
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      FirebaseService.setCurrentUserOnline(state: true);
    else
      FirebaseService.setCurrentUserOnline(state: false);
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: Builder(
            builder: (context) => InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding / 4.0),
                child: CircularProfilePicture(
                  email: FirebaseService.currentUserEmail,
                  radius: kDefaultBorderRadius,
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          title: Text('Hi'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.messenger),
                    SizedBox(width: kDefaultPadding / 4.0),
                    Text('Chats')
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.group_rounded),
                    SizedBox(width: kDefaultPadding / 4.0),
                    Text('Friends')
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.notifications),
                    SizedBox(width: kDefaultPadding / 4.0),
                    Text('Requests'),
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: Scaffold(
            appBar: AppBar(
                title: Text('Hi'),
                automaticallyImplyLeading: false,
                backgroundColor: kPrimaryColor),
            body: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: kDefaultPadding / 2.0,
                  vertical: kDefaultPadding / 4.0),
              child: Column(
                children: [
                  CircularProfilePicture(
                    email: FirebaseService.currentUserEmail,
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.black),
                    title: TextStreamBuilder(
                      stream: FirebaseService.getStreamToUserData(
                          email: FirebaseService.currentUserEmail),
                      key: UserDocumentField.DISPLAY_NAME,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.black),
                    title: Text(
                      FirebaseService.currentUserEmail,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  RoundIconButton(
                      icon: Icons.edit,
                      onPressed: () =>
                          Navigator.pushNamed(context, EditProfileScreen.id),
                      color: Colors.blueGrey),
                  Divider(
                    color: Colors.grey,
                  ),
                  PrimaryButton(
                    displayText: 'Sign Out',
                    onPressed: () async {
                      await FirebaseService.setCurrentUserOnline(state: false);
                      FirebaseService.signOut();
                      Navigator.popAndPushNamed(context, WelcomeScreen.id);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              ChatTab(),
              FriendsTab(),
              RequestsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
