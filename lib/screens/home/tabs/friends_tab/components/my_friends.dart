import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';

class MyFriends extends StatelessWidget {
  const MyFriends();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){}, child: Icon(Icons.search), backgroundColor: kPrimaryColor),
      body: Text('My Friends'),
    );
  }
}