import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/friend_card.dart';
import 'package:hi/services/firebase_service.dart';

class MyFriends extends StatelessWidget {
  const MyFriends();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet(
              context: context, builder: (context) => AddByEmail());
          if (result != null && result == true) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Request Sent.')));
          }
        },
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.currentUserStreamToFriends,
        builder: (context, snapshot) {
          List<FriendCard> friendList = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final friends = snapshot.data?.docs;
            if (friends != null) {
              for (final friend in friends) {
                final friendEmail = friend['email'];
                friendList.add(FriendCard(
                  friendEmail: friendEmail,
                ));
              }
            }
          }
          return ListView(
            children: friendList,
          );
        },
      ),
    );
  }
}

//Bottom Sheet
class AddByEmail extends StatefulWidget {
  @override
  _AddByEmailState createState() => _AddByEmailState();
}

class _AddByEmailState extends State<AddByEmail> {
  final _borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefaultBorderRadius * 2)),
    borderSide: BorderSide(color: kPrimaryColor),
  );

  final _formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();

  final _validator =
      (String? value) => value!.trim().isEmpty ? 'Enter an email.' : null;

  String? firebaseError;

  bool isLoading = false;

  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      showIndicator: isLoading,
      child: Container(
        color: Color(0xFF737373),
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding / 2.0,
                    vertical: kDefaultPadding),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _textEditingController,
                    validator: _validator,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: firebaseError,
                      filled: true,
                      fillColor: const Color(0x112EA043),
                      labelText: 'Your friend\'s email',
                      enabledBorder: _borderRadius,
                      focusedBorder: _borderRadius,
                      errorBorder: _borderRadius,
                      focusedErrorBorder: _borderRadius,
                      prefixIcon: Icon(Icons.mail),
                    ),
                  ),
                ),
              ),
              SizedBox(height: kDefaultPadding / 4.0),
              PrimaryButton(
                displayText: 'Send Request',
                onPressed: () async {
                  setLoading(true);
                  if (_formKey.currentState!.validate()) {
                    firebaseError = null;
                    await FirebaseService.sendFriendRequest(
                            recipientEmail: _textEditingController.text.trim())
                        .then((value) {
                      setLoading(false);
                      Navigator.pop(context, true);
                    }).catchError((error) {
                      setState(() {
                        firebaseError = error;
                      });
                    });
                  }
                  setLoading(false);
                },
              )
            ],
          ),
          height: MediaQuery.of(context).size.height / 2.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kDefaultBorderRadius),
              topRight: Radius.circular(kDefaultBorderRadius),
            ),
          ),
        ),
      ),
    );
  }
}
