import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/provider/helper/message.dart';
import 'package:hi/provider/selected_messages.dart';
import 'package:hi/screens/chat/image_view_screen.dart/image_view_screen.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class GroupImageMessage extends StatefulWidget {
  final Message _message;
  final bool _selectionMode;
  final _selectionModeManager;
  const GroupImageMessage(
      {required final Message message,
      required final selectionMode,
      required final selectionModeManager})
      : _message = message,
        _selectionMode = selectionMode,
        _selectionModeManager = selectionModeManager;

  @override
  _GroupImageMessageState createState() => _GroupImageMessageState();
}

class _GroupImageMessageState extends State<GroupImageMessage> {
  bool get isSelected => Provider.of<SelectedMessages>(context, listen: false)
      .contain(messageId: widget._message.messageId);

  @override
  Widget build(BuildContext context) {
    final displaySize = MediaQuery.of(context).size;
    bool isMe = widget._message.sender == FirebaseService.currentUserEmail;
    bool multiImages = widget._message.imageUrls!.length > 1;
    final borderRaidus = BorderRadius.only(
      topLeft: Radius.circular(kDefualtBorderRadius),
      topRight: Radius.circular(kDefualtBorderRadius),
      bottomRight: isMe ? Radius.zero : Radius.circular(kDefualtBorderRadius),
      bottomLeft: isMe ? Radius.circular(kDefualtBorderRadius) : Radius.zero,
    );
    return InkWell(
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
              color: isSelected
                  ? Colors.grey
                  : isMe
                      ? Colors.white
                      : Color(0x992EA043),
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
                              email: widget._message.sender,
                              radius: displaySize.width * 0.03),
                          SizedBox(width: kDefaultPadding / 4.0),
                          TextStreamBuilder(
                            stream: FirebaseService.getStreamToUserData(
                                email: widget._message.sender),
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
                            image: NetworkImage(widget._message.imageUrls![0]),
                            width: displaySize.width * 0.80,
                            height: displaySize.height * 0.60,
                            fit: BoxFit.cover,
                          ),
                          if (multiImages)
                            PrimaryButton(
                              onPressed: widget._selectionMode
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (cotext) => ImageViewScreen(
                                              imageURLs: widget._message
                                                  .imageUrls as List<String>),
                                        ),
                                      );
                                    },
                              displayText:
                                  '${widget._message.imageUrls!.length - 1} More',
                              color: Colors.black.withOpacity(0.05),
                            ),
                        ],
                      ),
                      borderRadius: isMe
                          ? borderRaidus
                          : borderRaidus.copyWith(topLeft: Radius.circular(0)),
                    ),
                    if (widget._message.content != null)
                      SizedBox(height: kDefaultPadding / 5.0),
                    if (widget._message.content != null)
                      Text(
                        widget._message.content as String,
                        style: TextStyle(
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    SizedBox(height: kDefaultPadding / 5.0),
                    Text(
                      widget._message.time,
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
      onTap: widget._selectionMode
          ? () {
              setState(() {
                if (isSelected) {
                  Provider.of<SelectedMessages>(context, listen: false)
                      .removeMessage(messageId: widget._message.messageId);
                  if (Provider.of<SelectedMessages>(context, listen: false)
                      .isEmpty) widget._selectionModeManager(false);
                } else {
                  Provider.of<SelectedMessages>(context, listen: false)
                      .addMessage(message: widget._message);
                }
              });
            }
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (cotext) => ImageViewScreen(
                      imageURLs: widget._message.imageUrls as List<String>),
                ),
              );
            },
      onLongPress: widget._selectionMode
          ? null
          : () {
              setState(() {
                Provider.of<SelectedMessages>(context, listen: false)
                    .addMessage(message: widget._message);
                widget._selectionModeManager(true);
              });
            },
    );
  }
}
