import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';
import 'package:hi/services/firebase_service.dart';

class ImageMessageTextField extends StatefulWidget {
  final List<File> _images;
  final String _friendEmail;
  final String _roomId;
  final Function _progressIndicatorCallback;
  ImageMessageTextField(
      {required final String roomId,
      required final String friendEmail,
      required final List<File> images,
      required final Function progressIndicatorCallback})
      : _roomId = roomId,
        _friendEmail = friendEmail,
        _images = images,
        _progressIndicatorCallback = progressIndicatorCallback;

  @override
  _ImageMessageTextFieldState createState() => _ImageMessageTextFieldState();
}

class _ImageMessageTextFieldState extends State<ImageMessageTextField> {
  final TextEditingController _textEditingController = TextEditingController();

  final _borderRadius = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefualtBorderRadius * 2)),
    borderSide: BorderSide(color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              controller: _textEditingController,
              minLines: 1,
              maxLines: 6,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'about photos...',
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
          SizedBox(width: kDefaultPadding / 3.0),
          RoundIconButton(
            icon: Icons.send,
            onPressed: () async {
              widget._progressIndicatorCallback(true);
              final String? message = _textEditingController.text.trim().isNotEmpty ? _textEditingController.text.trim() : null;
              await FirebaseService.sendImagesToFriend(friendEmail: widget._friendEmail, roomId: widget._roomId, images: widget._images, message: message).then((value){
                widget._progressIndicatorCallback(false);
                Navigator.pop(context);
              });
            },
            radius: 50.0,
          ),
        ],
      ),
    );
  }
}
