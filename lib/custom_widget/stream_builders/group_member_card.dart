import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/profile_view/user_profile_view_screen.dart';
import 'package:hi/services/firebase_service.dart';
import 'online_indicator_dot.dart';

class GroupMemberCard extends StatelessWidget {
  final String _memberEmail;
  final bool _isCurrentUserAdmin;
  const GroupMemberCard(
      {required final String memberEmail,
      required final bool isCurrentUserAdmin})
      : _memberEmail = memberEmail,
        _isCurrentUserAdmin = isCurrentUserAdmin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding / 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProfilePicture(
              email: _memberEmail,
              radius: kDefualtBorderRadius * 1.5,
            ),
            SizedBox(width: kDefaultPadding / 2.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextStreamBuilder(
                        stream: FirebaseService.getStreamToUserData(
                            email: _memberEmail),
                        key: UserDocumentField.DISPLAY_NAME,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 2.5,
                        ),
                      ),
                      SizedBox(width: kDefaultPadding / 4.0),
                      OnlineIndicatorDot(email: _memberEmail)
                    ],
                  ),
                  TextStreamBuilder(
                    stream: FirebaseService.getStreamToUserData(
                        email: _memberEmail),
                    key: UserDocumentField.ABOUT,
                    textOverflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),
            if (_isCurrentUserAdmin &&
                _memberEmail != FirebaseService.currentUserEmail)
              IconButton(
                onPressed: () async{
                  final result = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Remove'),
                      content: FutureBuilder(
                        future: FirebaseService.getNameOf(email: _memberEmail),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError || snapshot.data == null)
                              return Text('Something went wrong!');
                            else
                              return Text(
                                  'Are you sure to remove ${snapshot.data as String}?');
                          }
                          return Text(
                            'Loadig....',
                            style: TextStyle(color: Colors.grey),
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('No'),
                        ),
                      ],
                    ),
                  );
                  if(result != null && result != false){
                    //TODO:Remove User From GROUP
                  }
                },
                icon: Icon(Icons.exit_to_app_outlined),
              )
          ],
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userEmail: _memberEmail),
        ),
      ),
    );
  }
}
