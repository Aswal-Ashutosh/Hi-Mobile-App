import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/profile_view/user_profile_view_screen.dart';
import 'package:hi/services/firebase_service.dart';

class FriendRequestCard extends StatelessWidget {
  final _senderEmail;
  final _time;
  final _date;

  const FriendRequestCard(
      {required final senderEmail, required final time, required final date})
      : _senderEmail = senderEmail,
        _time = time,
        _date = date;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userEmail: _senderEmail),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularProfilePicture(
              email: _senderEmail,
              radius: kDefualtBorderRadius * 2.5,
            ),
            SizedBox(width: kDefaultPadding / 5.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextStreamBuilder(
                    stream: FirebaseService.getStreamToUserData(
                        email: _senderEmail),
                    key: UserDocumentField.DISPLAY_NAME,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      letterSpacing: 2.5,
                    ),
                  ),
                  SizedBox(height: kDefaultPadding / 5.0),
                  Text(
                    _senderEmail,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 2.5,
                    ),
                  ),
                  SizedBox(height: kDefaultPadding / 5.0),
                  Text(
                    '${_date as String} at ${_time as String}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => FirebaseService.acceptFriendRequest(
                              email: _senderEmail),
                          child: Text(
                            'ACCEPT',
                            style: TextStyle(color: Colors.green),
                          )),
                      TextButton(
                        onPressed: () => FirebaseService.rejectFreindRequest(
                            email: _senderEmail),
                        child: Text(
                          'REJECT',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
