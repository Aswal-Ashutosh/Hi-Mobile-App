import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/conditional_stream_builder.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/services/firebase_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String _userEmail;
  const UserProfileScreen({required final String userEmail})
      : _userEmail = userEmail;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      showIndicator: isLoading,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: TextStreamBuilder(
            stream:
                FirebaseService.getStreamToUserData(email: widget._userEmail),
            key: UserDocumentField.DISPLAY_NAME,
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: SafeArea(
          child: Body(
            userEmail: widget._userEmail,
            progressIndicatorCallback: setLoading,
            scaffoldKey: _scaffoldKey,
          ),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    Key? key,
    required final String userEmail,
    required final Function progressIndicatorCallback,
    required final GlobalKey<ScaffoldState> scaffoldKey,
  })  : _userEmail = userEmail,
        _progressIndicatorCallback = progressIndicatorCallback,
        _scaffoldKey = scaffoldKey,
        super(key: key);

  final String _userEmail;
  final Function _progressIndicatorCallback;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        children: [
          CircularProfilePicture(
            email: _userEmail,
          ),
          SizedBox(height: kDefaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.person, color: Colors.grey[700]),
              SizedBox(width: kDefaultPadding),
              TextStreamBuilder(
                stream: FirebaseService.getStreamToUserData(email: _userEmail),
                key: UserDocumentField.DISPLAY_NAME,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: kDefaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, color: Colors.grey[700]),
              SizedBox(width: kDefaultPadding),
              Flexible(
                flex: 5,
                child: TextStreamBuilder(
                  stream:
                      FirebaseService.getStreamToUserData(email: _userEmail),
                  key: UserDocumentField.ABOUT,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: kDefaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.email, color: Colors.grey[700]),
              SizedBox(width: kDefaultPadding),
              Flexible(
                flex: 5,
                child: Text(
                  _userEmail,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          ConditionalStreamBuilder(
            stream: FirebaseService.getStreamToFriendDoc(email: _userEmail),
            childIfExist: PrimaryButton(
              displayText: 'Unfriend',
              onPressed: () async {
                _progressIndicatorCallback(true);
                await FirebaseService.unfriend(email: _userEmail);
                _progressIndicatorCallback(false);
              },
              color: Colors.redAccent,
            ),
            childIfDoNotExist: PrimaryButton(
              displayText: 'Add Friend',
              onPressed: () async {
                _progressIndicatorCallback(true);
                String result = await FirebaseService.sendFriendRequest(
                        recipientEmail: _userEmail)
                    .then((value) => 'Request Sent.')
                    .catchError((error) => error);
                ScaffoldMessenger.of(
                        _scaffoldKey.currentContext as BuildContext)
                    .showSnackBar(
                  SnackBar(
                    content: Text(result),
                  ),
                );
                _progressIndicatorCallback(false);
              },
              color: kSecondaryColor,
            ),
          )
        ],
      ),
    );
  }
}
