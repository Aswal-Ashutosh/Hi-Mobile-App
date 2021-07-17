import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/screens/home/tabs/requests_tab/requests_tab.dart';
import 'package:hi/screens/home/tabs/chat_tab/chat_tab.dart';
import 'package:hi/screens/home/tabs/friends_tab/friends_tab.dart';

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
          automaticallyImplyLeading: false,
          actions: [Padding(
            padding: const EdgeInsets.only(right: kDefaultPadding / 4.0),
            child: Icon(Icons.settings),
          )],
          title: Text('Hi'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(child: Row(
                children: [
                  Icon(Icons.messenger),
                  SizedBox(width: kDefaultPadding / 4.0),
                  Text('Chats')
                ],
              ),),
              Tab(child: Row(
                children: [
                  Icon(Icons.group_rounded),
                  SizedBox(width: kDefaultPadding / 4.0),
                  Text('Friends')
                ],
              ),),
              Tab(child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: kDefaultPadding / 4.0),
                  Text('Requests'),
                ],
              ),),
            ],
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
