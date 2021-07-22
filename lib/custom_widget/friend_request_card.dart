import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/profile_picture_stream_builder.dart';
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
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding / 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ProfilePictureStreamBuilder(
            stream:
                FirebaseService.getStreamToProfilePicture(email: _senderEmail),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: FirebaseService.getNameOf(email: _senderEmail),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data as String,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                        letterSpacing: 2.5,
                      ),
                    );
                  } else {
                    //TODO: Add shimmer
                    return Text('Loading...', style: TextStyle(color: Colors.grey),);
                  }
                },
              ),
              SizedBox(height: kDefaultPadding / 5.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: new Text(
                        _senderEmail,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 2.5,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: kDefaultPadding / 4.0),
              Text(
                '${_date as String} at ${_time as String}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => FirebaseService.acceptFriendRequest(email: _senderEmail),
                        child: Text(
                          'ACCEPT',
                          style: TextStyle(color: Colors.green),
                        )),
                    TextButton(
                      onPressed: () => FirebaseService.rejectFreindRequest(email: _senderEmail),
                      child: Text(
                        'REJECT',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
