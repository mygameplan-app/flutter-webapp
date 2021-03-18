import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;

  RoundedButton({
    this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 48.0),
        child: child,
        onPressed: onPressed,
      ),
    );
  }
}
