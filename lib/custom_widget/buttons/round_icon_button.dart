import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final onPressed;
  final Color color;

  const RoundIconButton({required this.icon, required this.onPressed, this.color = kPrimaryColor});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: CircleBorder(),
      fillColor: color,
      onPressed: onPressed,
      elevation: 5.0,
      child: Icon(icon, color: Colors.white,),
    );
  }
}