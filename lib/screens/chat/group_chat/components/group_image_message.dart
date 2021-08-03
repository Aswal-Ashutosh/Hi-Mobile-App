import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/image_view_screen.dart/image_view_screen.dart';
import 'package:hi/services/firebase_service.dart';

class GroupImageMessage extends StatelessWidget {
  final String _id;
  final String _sender;
  final String? _content;
  final String _time;
  final List<String> _imageUrl;
  const GroupImageMessage(
      {required final String id,
      required final String sender,
      required final String? content,
      required final String time,
      required final List<String> imageUrl})
      : _id = id,
        _sender = sender,
        _content = content,
        _time = time,
        _imageUrl = imageUrl;
  @override
  Widget build(BuildContext context) {
    final displaySize = MediaQuery.of(context).size;
    bool isMe = _sender == FirebaseService.currentUserEmail;
    bool multiImages = _imageUrl.length > 1;
    final borderRaidus = BorderRadius.only(
      topLeft: Radius.circular(kDefualtBorderRadius),
      topRight: Radius.circular(kDefualtBorderRadius),
      bottomRight: isMe ? Radius.zero : Radius.circular(kDefualtBorderRadius),
      bottomLeft: isMe ? Radius.circular(kDefualtBorderRadius) : Radius.zero,
    );
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (cotext) => ImageViewScreen(imageURLs: _imageUrl),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
            top: kDefaultPadding / 5.0,
            bottom: kDefaultPadding / 5.0,
            left: isMe ? displaySize.width * .20 : kDefaultPadding / 5.0,
            right: isMe ? kDefaultPadding / 5.0 : displaySize.width * .20),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 1.0,
              color: isMe ? Color(0xAA2EA043) : Color(0xAA1F6FEB),
              borderRadius: borderRaidus,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Row(
                        children: [
                          CircularProfilePicture(
                              email: _sender, radius: displaySize.width * 0.03),
                          SizedBox(width: kDefaultPadding / 4.0),
                          TextStreamBuilder(
                            stream: FirebaseService.getStreamToUserData(
                                email: _sender),
                            key: UserDocumentField.DISPLAY_NAME,
                            style: TextStyle(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                    if (!isMe) SizedBox(height: kDefaultPadding / 4.0),
                    ClipRRect(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image(
                            image: NetworkImage(_imageUrl[0]),
                            width: displaySize.width * 0.80,
                            height: displaySize.height * 0.60,
                            fit: BoxFit.cover,
                          ),
                          if (multiImages)
                            PrimaryButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (cotext) =>
                                        ImageViewScreen(imageURLs: _imageUrl),
                                  ),
                                );
                              },
                              displayText: '${_imageUrl.length - 1} More',
                              color: Colors.black.withOpacity(0.05),
                            ),
                        ],
                      ),
                      borderRadius: isMe ? borderRaidus : borderRaidus.copyWith(topLeft: Radius.circular(0)),
                    ),
                    if (_content != null)
                      SizedBox(height: kDefaultPadding / 5.0),
                    if (_content != null)
                      Text(
                        _content as String,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    SizedBox(height: kDefaultPadding / 5.0),
                    Text(
                      _time,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
