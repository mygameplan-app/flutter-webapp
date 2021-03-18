import 'package:flutter/material.dart';

class CircleItem extends StatelessWidget {
  final String title;
  final Color color;
  final Color outlineColor;
  final Function onTap;
  final bool selected;
  final IconData iconData;
  CircleItem(
      {this.title,
      this.color,
      this.outlineColor,
      this.onTap,
      this.selected,
      this.iconData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: this.selected ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  this.color.withAlpha(240),
                  this.color.withAlpha(80),
                ],
              ),
              border: Border.all(color: this.outlineColor, width: 3.0)),
          height: 100,
          width: 100,
          padding: EdgeInsets.all(4),
          margin: EdgeInsets.all(10),
          child: Center(
            child: iconData == null
                ? Text(
                    title,
                    style: TextStyle(
                      color: this.outlineColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Icon(
                    iconData,
                    size: 30,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}
