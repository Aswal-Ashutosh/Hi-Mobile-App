import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hi/screens/chat/one_to_one/image_message_preview_screen/image_message_text_field.dart';
import 'package:photo_view/photo_view.dart';

class ImageMessagePreviewScreen extends StatelessWidget {
  final List<File> _images;
  final String _friendEmail;
  final String _roomId;
  ImageMessagePreviewScreen(
      {required final String roomId,
      required final String friendEmail,
      required final List<File> images})
      : _roomId = roomId,
        _friendEmail = friendEmail,
        _images = images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => PhotoView(
                imageProvider: FileImage(
                  _images[index],
                ),
              ),
              itemCount: _images.length,
            ),
            Positioned(
              child: ImageMessageTextField(
                  roomId: _roomId, friendEmail: _friendEmail, images: _images),
              bottom: 0,
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
