import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/screens/home/home_screen.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  static const id = 'profile_setup_screen';

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameTextController = TextEditingController();
  final _aboutTextController = TextEditingController(text: 'Hi 🤗.');

  final _validator = (String? value) =>
      value!.trim().isEmpty ? "This field can't be empty." : null;

  final borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefaultBorderRadius * 2)),
    borderSide: BorderSide(color: kPrimaryColor),
  );

  File? profileImage;

  bool isLoading = false;

  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _aboutTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      showIndicator: isLoading,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text('Setup Profile'), backgroundColor: kPrimaryColor),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              children: [
                Stack(
                  children: [
                    profileImage == null
                        ? CircleAvatar(
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: kDefaultBorderRadius * 3,
                            ),
                            backgroundColor: Colors.blueGrey,
                            radius: kDefaultBorderRadius * 3,
                          )
                        : CircleAvatar(
                            backgroundImage: FileImage(profileImage as File),
                            backgroundColor: Colors.blueGrey,
                            radius: kDefaultBorderRadius * 3,
                          ),
                    Positioned(
                      child: RoundIconButton(
                        icon: Icons.edit,
                        onPressed: () async {
                          final ImagePicker imagePicker = ImagePicker();
                          XFile? image = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              profileImage = File(image.path);
                            });
                          }
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
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameTextController,
                        validator: _validator,
                        textAlign: TextAlign.center,
                        maxLength: 20,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0x112EA043),
                          labelText: 'Your Name',
                          enabledBorder: borderRadius,
                          focusedBorder: borderRadius,
                          errorBorder: borderRadius,
                          focusedErrorBorder: borderRadius,
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: kDefaultPadding),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        controller: _aboutTextController,
                        validator: _validator,
                        textAlign: TextAlign.left,
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 120,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0x112EA043),
                          labelText: 'About',
                          enabledBorder: borderRadius,
                          focusedBorder: borderRadius,
                          errorBorder: borderRadius,
                          focusedErrorBorder: borderRadius,
                          prefixIcon: Icon(Icons.menu_book),
                        ),
                      ),
                      SizedBox(height: kDefaultPadding),
                      PrimaryButton(
                        displayText: 'Save',
                        onPressed: () async {
                          setLoading(true);
                          if (_formKey.currentState!.validate()) {
                            await FirebaseService.createNewUser(
                                    email: FirebaseService.currentUserEmail,
                                    name: _nameTextController.text.trim(),
                                    about: _aboutTextController.text.trim(),
                                    profileImage: profileImage)
                                .then((value) {
                                  setLoading(false);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, HomeScreen.id, (route) => false);
                            });
                          }
                          setLoading(false);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
