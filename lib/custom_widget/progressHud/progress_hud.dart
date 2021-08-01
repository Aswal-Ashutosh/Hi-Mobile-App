import 'package:flutter/material.dart';

class ProgressHUD extends StatelessWidget {
  final Widget _child;
  final bool _showIndicator;
  const ProgressHUD({required final Widget child, required final bool showIndicator}): _child = child, _showIndicator = showIndicator;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _showIndicator,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _child,
          if(_showIndicator) CircularProgressIndicator()
        ],
      ),
    );
  }
}