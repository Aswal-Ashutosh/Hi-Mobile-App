import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/screens/chat/one_to_one/image_message_preview_screen/image_message_text_field.dart';
import 'package:photo_view/photo_view.dart';

class ImageMessagePreviewScreen extends StatefulWidget {
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
  _ImageMessagePreviewScreenState createState() => _ImageMessagePreviewScreenState();
}

class _ImageMessagePreviewScreenState extends State<ImageMessagePreviewScreen> {
  bool isLoading = false;
  void setLoading(bool condition){
    setState(() {
      isLoading = condition;
    });
  }
  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      showIndicator: isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) => PhotoView(
                  imageProvider: FileImage(
                    widget._images[index],
                  ),
                ),
                itemCount: widget._images.length,
              ),
              Positioned(
                child: ImageMessageTextField(
                    roomId: widget._roomId, friendEmail: widget._friendEmail, images: widget._images, progressIndicatorCallback: setLoading),
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
      ),
    );
  }
}
