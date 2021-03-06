import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/provider/helper/message.dart';
import 'package:hi/provider/selected_messages.dart';
import 'package:hi/screens/chat/image_view_screen.dart/image_view_screen.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class ImageMessage extends StatefulWidget {
  final Message _message;
  final bool _selectionMode;
  final _selectionModeManager;
  const ImageMessage(
      {required final Message message,
      required final selectionMode,
      required final selectionModeManager})
      : _message = message,
        _selectionMode = selectionMode,
        _selectionModeManager = selectionModeManager;

  @override
  _ImageMessageState createState() => _ImageMessageState();
}

class _ImageMessageState extends State<ImageMessage> {
  bool get isSelected => Provider.of<SelectedMessages>(context, listen: false)
      .contain(messageId: widget._message.messageId);

  @override
  Widget build(BuildContext context) {
    final displaySize = MediaQuery.of(context).size;
    bool isMe = widget._message.sender == FirebaseService.currentUserEmail;
    bool multiImages = widget._message.imageUrls!.length > 1;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(kDefaultBorderRadius),
      topRight: Radius.circular(kDefaultBorderRadius),
      bottomRight: isMe ? Radius.zero : Radius.circular(kDefaultBorderRadius),
      bottomLeft: isMe ? Radius.circular(kDefaultBorderRadius) : Radius.zero,
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
              borderRadius: borderRadius,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
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
                                          builder: (context) => ImageViewScreen(
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
                      borderRadius: borderRadius,
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
                  builder: (context) => ImageViewScreen(
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
