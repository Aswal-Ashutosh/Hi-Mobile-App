import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/screens/home/tabs/friends_tab/components/add_friends.dart';
import 'package:hi/screens/home/tabs/friends_tab/components/my_friends.dart';

class FriendsTab extends StatefulWidget {
  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  static int _currentIndex = 0;
  static const List<Widget> _views = <Widget>[MyFriends(), AddFriends()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'My Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Add Friends'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: kSecondaryColor,
        onTap: (index){ setState(() { _currentIndex = index; }); },
      ),
    );
  }
}