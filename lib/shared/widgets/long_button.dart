import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final IconData icon;
  final Color color;
  final Color textColor;
  LongButton(
      {this.text, this.onPressed, this.icon, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 14.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onPressed: onPressed,
              color: color,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Icon(icon, size: 32.0),
                        )
                      : Container(),
                  SizedBox(width: icon == null ? 0 : 12),
                  Expanded(
                    child: Text(
                      text.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(fontSize: 14.0, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
