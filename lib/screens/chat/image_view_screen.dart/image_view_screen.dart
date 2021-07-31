import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewScreen extends StatelessWidget {
  final List<String> _imageURLs;
  const ImageViewScreen({required final List<String> imageURLs})
      : _imageURLs = imageURLs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => PhotoView(
                imageProvider: NetworkImage(_imageURLs[index]),
              ),
              itemCount: _imageURLs.length,
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
              ),
          ],
        ),
      ),
    );
  }
}
