import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/provider/selected_users.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class SelectionCard extends StatefulWidget {
  final _friendEmail;
  const SelectionCard({required final friendEmail}) : _friendEmail = friendEmail;

  @override
  _SelectionCardState createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        color: isSelected ? Color(0x552EA043) : Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(kDefaultPadding / 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProfilePicture(
              email: widget._friendEmail,
              radius: kDefualtBorderRadius * 1.5,
            ),
            SizedBox(width: kDefaultPadding / 2.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextStreamBuilder(
                        stream: FirebaseService.getStreamToUserData(
                            email: widget._friendEmail),
                        key: UserDocumentField.DISPLAY_NAME,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 2.5,
                        ),
                      ),
                      if(isSelected) ClipOval(child: Container(child: Icon(Icons.done, color: Colors.white, size: 20), color: Colors.green))
                    ],
                  ),
                  TextStreamBuilder(
                    stream: FirebaseService.getStreamToUserData(
                        email: widget._friendEmail),
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
            )
          ],
        ),
      ),
      onTap: () {
        setState(() {
          if(isSelected){
            Provider.of<SelectedUsers>(context, listen: false).removeUser(email: widget._friendEmail);
          }else{
            Provider.of<SelectedUsers>(context, listen: false).addUser(email: widget._friendEmail);
          }
          isSelected = !isSelected;
        });
      },
    );
  }
}
