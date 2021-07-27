import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';

class MessageTextField extends StatelessWidget {
  final TextEditingController _textEditingController;
  final Function _onSend;

  final _borderRadius = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefualtBorderRadius * 2)),
    borderSide: BorderSide(color: Colors.white),
  );

  MessageTextField(
      {required final TextEditingController controller,
      required final Function onSend})
      : _textEditingController = controller,
        _onSend = onSend;

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
                          color: Colors.grey,
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
                      Scaffold.of(context)
                          .showBottomSheet((context) => SharePopUpMenu());
                    },
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(kDefualtBorderRadius * 2.0),
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
          RoundIconButton(icon: Icons.mic, onPressed: () {}, radius: 50.0),
          SizedBox(width: kDefaultPadding / 4.0),
          RoundIconButton(icon: Icons.send, onPressed: _onSend, radius: 50.0),
        ],
      ),
    );
  }
}

class SharePopUpMenu extends StatefulWidget {
  const SharePopUpMenu({Key? key}) : super(key: key);

  @override
  _SharePopUpMenuState createState() => _SharePopUpMenuState();
}

class _SharePopUpMenuState extends State<SharePopUpMenu> {
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
            RoundIconButton(icon: Icons.image, onPressed: () {}),
            RoundIconButton(icon: Icons.video_collection, onPressed: () {}),
            RoundIconButton(icon: Icons.file_copy, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
