import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/round_icon_button.dart';

class MessageTextField extends StatelessWidget {
  final _borderRadius = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefualtBorderRadius * 2)),
    borderSide: BorderSide(color: Colors.white),
  );

  final TextEditingController _textEditingController = TextEditingController();

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
          RoundIconButton(icon: Icons.send, onPressed: () {}, radius: 50.0)
        ],
      ),
    );
  }
}
