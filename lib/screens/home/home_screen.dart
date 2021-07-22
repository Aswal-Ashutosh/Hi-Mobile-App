import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/user_name_text.dart';
import 'package:hi/screens/edit_profile/edit_profile_screen.dart';
import 'package:hi/screens/home/tabs/requests_tab/requests_tab.dart';
import 'package:hi/screens/home/tabs/chat_tab/chat_tab.dart';
import 'package:hi/screens/home/tabs/friends_tab/friends_tab.dart';
import 'package:hi/screens/welcome_screen.dart';
import 'package:hi/services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  static const id = 'home_screen';
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
                  stream: FirebaseService.currentUserStreamToProfilePicture,
                  radius: kDefualtBorderRadius,
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
                    stream: FirebaseService.currentUserStreamToProfilePicture,
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: UserNameText(
                      email: FirebaseService.currentUserEmail,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  ListTile(
                      leading: Icon(Icons.email),
                      title: Text(FirebaseService.currentUserEmail,
                          style: TextStyle(fontSize: 10, letterSpacing: 2.5))),
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
