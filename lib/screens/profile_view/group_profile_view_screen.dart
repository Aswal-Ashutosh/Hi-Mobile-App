import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/group_member_card.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/group/group_chat_add_member_screen.dart';
import 'package:hi/screens/profile_view/user_profile_view_screen.dart';
import 'package:hi/services/firebase_service.dart';

class GroupProfileScreen extends StatefulWidget {
  final String _roomId;
  const GroupProfileScreen({required final String roomId}) : _roomId = roomId;
  @override
  _GroupProfileScreenState createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  String? adminEmail;
  bool? isCurrentUserAdmin;

  @override
  void initState() {
    getAdmin();
    super.initState();
  }

  void getAdmin() async {
    adminEmail = await FirebaseService.getGroupData(
        roomId: widget._roomId, key: ChatDBDocumentField.GROUP_ADMIN);
    setState(() {
      isCurrentUserAdmin = adminEmail == FirebaseService.currentUserEmail;
    });
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
                FirebaseService.getStreamToGroupData(roomId: widget._roomId),
            key: ChatDBDocumentField.GROUP_NAME,
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: SafeArea(
          child: adminEmail == null
              ? Center(child: CircularProgressIndicator())
              : Body(
                  roomId: widget._roomId,
                  adminEmail: adminEmail as String,
                  isCurrentUserAdmin: isCurrentUserAdmin as bool,
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
    required final String roomId,
    required final String adminEmail,
    required final bool isCurrentUserAdmin,
    required final Function progressIndicatorCallback,
    required final GlobalKey<ScaffoldState> scaffoldKey,
  })  : _roomId = roomId,
        _adminEmail = adminEmail,
        _isCurrentUserAdmin = isCurrentUserAdmin,
        _progressIndicatorCallback = progressIndicatorCallback,
        _scaffoldKey = scaffoldKey,
        super(key: key);

  final String _roomId;
  final String _adminEmail;
  final bool _isCurrentUserAdmin;
  final Function _progressIndicatorCallback;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Stack(
              children: [
                CircularGroupProfilePicture(
                  roomId: _roomId,
                ),
                if (_isCurrentUserAdmin)
                  Positioned(
                    child: RoundIconButton(
                      icon: Icons.edit,
                      onPressed: () async {
                        if (await FirebaseService
                            .pickAndUploadGroupProfileImage(roomId: _roomId))
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Group Profile Picture Updated.'),
                            ),
                          );
                      },
                      color: Colors.blueGrey,
                    ),
                    right: 0,
                    bottom: 0,
                    width: kDefualtBorderRadius * 2.0,
                  )
              ],
            ),
            SizedBox(height: kDefaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.group, color: Colors.grey[700]),
                SizedBox(width: kDefaultPadding),
                TextStreamBuilder(
                  stream: FirebaseService.getStreamToGroupData(roomId: _roomId),
                  key: ChatDBDocumentField.GROUP_NAME,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 2.5,
                  ),
                ),
                if (_isCurrentUserAdmin) Spacer(),
                if (_isCurrentUserAdmin)
                  TextButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              NameEditingSheet(roomId: _roomId));
                      if (result != null && result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Group Name Updated.'),
                          ),
                        );
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
                    stream:
                        FirebaseService.getStreamToGroupData(roomId: _roomId),
                    key: ChatDBDocumentField.GROUP_ABOUT,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                if (_isCurrentUserAdmin) Spacer(),
                if (_isCurrentUserAdmin)
                  TextButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            AboutEditingSheet(roomId: _roomId),
                      );
                      if (result != null && result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('About Group Updated.'),
                          ),
                        );
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
                Icon(Icons.admin_panel_settings, color: Colors.grey[700]),
                SizedBox(width: kDefaultPadding),
                Admin(adminEmail: _adminEmail),
              ],
            ),
            Divider(),
            SizedBox(height: kDefaultPadding),
            Text('Group Members', style: TextStyle(color: Colors.grey)),
            SizedBox(height: kDefaultPadding / 2.0),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseService.getStreamToGroupData(roomId: _roomId),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.exists) {
                  final List<dynamic> members =
                      snapshot.data?[ChatDBDocumentField.MEMBERS];
                  final List<GroupMemberCard> memberCards = [];
                  members.forEach((email) {
                    memberCards.add(GroupMemberCard(
                      memberEmail: email,
                      roomId: _roomId,
                      isCurrentUserAdmin: _isCurrentUserAdmin,
                      progressIndicatorCallback: _progressIndicatorCallback,
                      scaffoldKey: _scaffoldKey,
                    ));
                  });
                  return Column(children: memberCards);
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
            SizedBox(height: kDefaultPadding / 2.0),
            Divider(
                indent: MediaQuery.of(context).size.width * 0.10,
                endIndent: MediaQuery.of(context).size.width * 0.10),
            _isCurrentUserAdmin
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrimaryButton(
                        displayText: 'Add Members',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GroupChatAddMemberScreen(roomId: _roomId),
                            ),
                          );
                          if (result != null && result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('New members added successfully.'),
                              ),
                            );
                          }
                        },
                        color: kSecondaryColor,
                      ),
                      SizedBox(width: kDefaultPadding),
                      PrimaryButton(
                        displayText: 'Delete Group',
                        onPressed: () {},
                        color: Colors.red,
                      ),
                    ],
                  )
                : PrimaryButton(
                    displayText: 'Leave Group',
                    onPressed: () {},
                    color: Colors.red,
                  )
          ],
        ),
      ),
    );
  }
}

//Bottom Sheet
class AboutEditingSheet extends StatefulWidget {
  final String _roomId;
  const AboutEditingSheet({required final String roomId}) : _roomId = roomId;
  @override
  _AboutEditingSheetState createState() => _AboutEditingSheetState();
}

class _AboutEditingSheetState extends State<AboutEditingSheet> {
  final _borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefualtBorderRadius * 2)),
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
    _textEditingController.text = await FirebaseService.getGroupData(
        roomId: widget._roomId, key: ChatDBDocumentField.GROUP_ABOUT);
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
                    await FirebaseService.updateGroupData(
                            roomId: widget._roomId,
                            key: ChatDBDocumentField.GROUP_ABOUT,
                            newValue: _textEditingController.text.trim())
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
              topLeft: Radius.circular(kDefualtBorderRadius),
              topRight: Radius.circular(kDefualtBorderRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class NameEditingSheet extends StatefulWidget {
  final String _roomId;
  const NameEditingSheet({required final String roomId}) : _roomId = roomId;
  @override
  _NameEditingSheetState createState() => _NameEditingSheetState();
}

class _NameEditingSheetState extends State<NameEditingSheet> {
  final _borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefualtBorderRadius * 2)),
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
    _textEditingController.text = await FirebaseService.getGroupData(
        roomId: widget._roomId, key: ChatDBDocumentField.GROUP_NAME);
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
                    maxLength: 40,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0x112EA043),
                      labelText: 'Group Name',
                      enabledBorder: _borderRadius,
                      focusedBorder: _borderRadius,
                      errorBorder: _borderRadius,
                      focusedErrorBorder: _borderRadius,
                      prefixIcon: Icon(Icons.group),
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
                    await FirebaseService.updateGroupData(
                            roomId: widget._roomId,
                            key: ChatDBDocumentField.GROUP_NAME,
                            newValue: _textEditingController.text.trim())
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
              topLeft: Radius.circular(kDefualtBorderRadius),
              topRight: Radius.circular(kDefualtBorderRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class Admin extends StatelessWidget {
  const Admin({
    Key? key,
    required String adminEmail,
  })  : _adminEmail = adminEmail,
        super(key: key);

  final String _adminEmail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userEmail: _adminEmail),
        ),
      ),
      child: TextStreamBuilder(
        stream: FirebaseService.getStreamToUserData(email: _adminEmail),
        key: UserDocumentField.DISPLAY_NAME,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}
