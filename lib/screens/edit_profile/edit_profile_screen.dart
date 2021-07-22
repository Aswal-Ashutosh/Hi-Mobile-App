import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/services/firebase_service.dart';

class EditProfileScreen extends StatelessWidget {
  static const id = 'edit_profile_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Edit Profile'), backgroundColor: kPrimaryColor),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                CircularProfilePicture(
                  stream: FirebaseService.currentUserStreamToProfilePicture,
                ),
                Positioned(
                  child: RoundIconButton(
                    icon: Icons.edit,
                    onPressed: () {
                      FirebaseService.pickAndUploadProfileImage();
                    },
                    color: Colors.blueGrey,
                  ),
                  right: 0,
                  bottom: 0,
                  width: kDefualtBorderRadius * 2.0,
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.person),
                SizedBox(width: kDefaultPadding),
                Text('Ashutosh Aswal'),
                Spacer(),
                TextButton(onPressed: () {}, child: Text('Change')),
              ],
            ),
            Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.email),
                SizedBox(width: kDefaultPadding),
                Text('ashu.aswal.333@gmail.com'),
                Spacer(),
                TextButton(onPressed: () {}, child: Text('Change')),
              ],
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
