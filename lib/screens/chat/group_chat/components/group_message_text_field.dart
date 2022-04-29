import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/screens/chat/group_chat/image_message_preview_screen/group_image_message_preview_screen.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:hi/services/image_picker_service.dart';

class GroupMessageTextField extends StatefulWidget {
  final String _roomId;

  GroupMessageTextField({required final roomId}):
        _roomId = roomId;

  @override
  _GroupMessageTextFieldState createState() => _GroupMessageTextFieldState();
}

class _GroupMessageTextFieldState extends State<GroupMessageTextField> {
  final TextEditingController _textEditingController = TextEditingController();

  final _borderRadius = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefaultBorderRadius * 2)),
    borderSide: BorderSide(color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding / 4.0, vertical: kDefaultPadding / 2.0),
      child: Row(
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(right: kDefaultPadding / 2.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _textEditingController,
                      minLines: 1,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Your message',
                        hintStyle: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                        enabledBorder: _borderRadius,
                        focusedBorder: _borderRadius,
                        errorBorder: _borderRadius,
                        focusedErrorBorder: _borderRadius,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    color: kPrimaryColor,
                    onPressed: () {
                      Scaffold.of(context).showBottomSheet(
                        (context) => SharePopUpMenu(
                          roomId: widget._roomId,
                        ),
                      );
                    },
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(kDefaultBorderRadius * 2.0),
                ),
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 1.0,
                    offset: Offset(0.0, 0.2),
                  )
                ],
              ),
            ),
          ),
          // RoundIconButton(icon: Icons.mic, onPressed: () {}, radius: 50.0),
          SizedBox(width: kDefaultPadding / 4.0),
          RoundIconButton(
            icon: Icons.send,
            onPressed: () async {
              final message = _textEditingController.text.trim();
              if (message.isNotEmpty) {
                _textEditingController.clear();
                await FirebaseService.sendTextMessageToRoom(
                  roomId: widget._roomId,
                  message: message,
                );
              }
            },
            radius: 50.0,
          ),
        ],
      ),
    );
  }
}

class SharePopUpMenu extends StatelessWidget {
  final String _roomId;
  const SharePopUpMenu({required final roomId}):
        _roomId = roomId;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      child: Container(
        color: Colors.white70,
        height: MediaQuery.of(context).size.height * 0.10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RoundIconButton(
                icon: Icons.image,
                onPressed: () async {
                  final List<File> pickedImages =
                      await ImagePickerService.pickMultiImagesFromGallery();
                  if (pickedImages.isNotEmpty) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupImageMessagePreviewScreen(
                          roomId: _roomId,
                          images: pickedImages,
                        ),
                      ),
                    );
                  }
                  Navigator.pop(context);
                }),
            RoundIconButton(icon: Icons.video_collection, onPressed: () {}),
            RoundIconButton(icon: Icons.file_copy, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
