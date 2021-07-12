import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String displayText;
  final Color color;
  final EdgeInsets padding;
  final onPressed;

  PrimaryButton({required this.displayText, this.color = kPrimaryButtonColor, this.padding = const EdgeInsets.all(kDefaultPadding * 0.75), required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      child: Text(displayText, style: TextStyle(color: Colors.white),),
      padding: padding,
      color: color,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40.0))),
    );
  }
}