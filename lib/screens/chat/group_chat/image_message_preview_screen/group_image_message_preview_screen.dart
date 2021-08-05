import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/screens/chat/group_chat/image_message_preview_screen/group_image_message_text_field.dart';
import 'package:photo_view/photo_view.dart';

class GroupImageMessagePreviewScreen extends StatefulWidget {
  final List<File> _images;
  final String _roomId;
  GroupImageMessagePreviewScreen(
      {required final String roomId, required final List<File> images})
      : _roomId = roomId,
        _images = images;

  @override
  _GroupImageMessagePreviewScreenState createState() =>
      _GroupImageMessagePreviewScreenState();
}

class _GroupImageMessagePreviewScreenState extends State<GroupImageMessagePreviewScreen> {
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
                child: GroupImageMessageTextField(
                    roomId: widget._roomId, images: widget._images, progressIndicatorCallback: setLoading),
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
