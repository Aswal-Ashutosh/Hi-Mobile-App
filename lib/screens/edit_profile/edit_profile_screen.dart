import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/edit_profile/profile_view_screen.dart';
import 'package:hi/services/firebase_service.dart';

class EditProfileScreen extends StatefulWidget {
  static const id = 'edit_profile_screen';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  bool isLoading = false;

  void setLoading(bool condition){
    setState(() {
      isLoading = condition;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: kPrimaryColor,
      ),
      body: SafeArea(
        child: ProgressHUD(
          showIndicator: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              children: [
                Stack(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseService.getStreamToUserData(
                          email: FirebaseService.currentUserEmail),
                      builder: (context, snapshots) {
                        void Function()? onTap = () {};
                        if (snapshots.hasData &&
                            snapshots.data != null &&
                            snapshots.data?['profile_image'] != null) {
                          final imageUrl = snapshots.data?['profile_image'];
                          onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileViewScreen(
                                    imageUrl: imageUrl),
                              ),
                            );
                          };
                        }
                        return GestureDetector(
                          child: CircularProfilePicture(
                            email: FirebaseService.currentUserEmail,
                          ),
                          onTap: onTap,
                        );
                      },
                    ),
                    Positioned(
                      child: RoundIconButton(
                        icon: Icons.edit,
                        onPressed: () async {
                          setLoading(true);
                          if (await FirebaseService.pickAndUploadProfileImage()){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Profile Picture Updated.'),
                              ),
                            );
                          }
                          setLoading(false);
                        },
                        color: Colors.blueGrey,
                      ),
                      right: 0,
                      bottom: 0,
                      width: kDefaultBorderRadius * 2.0,
                    )
                  ],
                ),
                SizedBox(height: kDefaultPadding),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: Colors.grey[700]),
                    SizedBox(width: kDefaultPadding),
                    TextStreamBuilder(
                      stream: FirebaseService.getStreamToUserData(
                          email: FirebaseService.currentUserEmail),
                      key: UserDocumentField.DISPLAY_NAME,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        letterSpacing: 2.5,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final result = await showModalBottomSheet(
                            context: context,
                            builder: (context) => NameEditingSheet());
                        if (result != null && result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Name Updated.')));
                        }
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.teal),
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
                        stream: FirebaseService.getStreamToUserData(
                            email: FirebaseService.currentUserEmail),
                        key: UserDocumentField.ABOUT,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final result = await showModalBottomSheet(
                            context: context,
                            builder: (context) => AboutEditingSheet());
                        if (result != null && result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('About Updated.')));
                        }
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.teal),
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
                        FirebaseService.currentUserEmail,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Bottom Sheet
class AboutEditingSheet extends StatefulWidget {
  @override
  _AboutEditingSheetState createState() => _AboutEditingSheetState();
}

class _AboutEditingSheetState extends State<AboutEditingSheet> {
  final _borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefaultBorderRadius * 2)),
    borderSide: BorderSide(color: kPrimaryColor),
  );

  final _formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();

  final _validator = (String? value) =>
      value!.trim().isEmpty ? 'This field can\'t be empty.' : null;

  @override
  void initState() {
    getOldAboutText();
    super.initState();
  }

  void getOldAboutText() async {
    _textEditingController.text =
        await FirebaseService.currentUserAboutFieldData;
  }

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
                    textInputAction: TextInputAction.done,
                    controller: _textEditingController,
                    validator: _validator,
                    textAlign: TextAlign.left,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 120,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0x112EA043),
                      labelText: 'About',
                      enabledBorder: _borderRadius,
                      focusedBorder: _borderRadius,
                      errorBorder: _borderRadius,
                      focusedErrorBorder: _borderRadius,
                      prefixIcon: Icon(Icons.menu_book),
                    ),
                  ),
                ),
              ),
              SizedBox(height: kDefaultPadding / 4.0),
              PrimaryButton(
                displayText: 'Update',
                onPressed: () async {
                  setLoading(true);
                  if (_formKey.currentState!.validate()) {
                    await FirebaseService.updateCurrentUserAboutField(
                            about: _textEditingController.text.trim())
                        .then((value) {
                      setLoading(false);
                      Navigator.pop(context, true);
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

class NameEditingSheet extends StatefulWidget {
  @override
  _NameEditingSheetState createState() => _NameEditingSheetState();
}

class _NameEditingSheetState extends State<NameEditingSheet> {
  final _borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefaultBorderRadius * 2)),
    borderSide: BorderSide(color: kPrimaryColor),
  );

  final _formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();

  final _validator = (String? value) =>
      value!.trim().isEmpty ? 'This field can\'t be empty.' : null;

  @override
  void initState() {
    getOldName();
    super.initState();
  }

  void getOldName() async {
    _textEditingController.text = await FirebaseService.currentUserName;
  }

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
                    maxLength: 20,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0x112EA043),
                      labelText: 'Your Name',
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
                displayText: 'Update',
                onPressed: () async {
                  setLoading(true);
                  if (_formKey.currentState!.validate()) {
                    await FirebaseService.updateCurrentUserNameField(
                            name: _textEditingController.text.trim())
                        .then((value) {
                      setLoading(false);
                      Navigator.pop(context, true);
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
