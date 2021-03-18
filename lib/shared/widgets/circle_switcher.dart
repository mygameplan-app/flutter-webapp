import 'package:flutter/material.dart';

import 'circle_item.dart';

class CircleSwitcher extends StatefulWidget {
  final List<CircleItem> items;
  final bool centered;

  CircleSwitcher({
    @required this.items,
    this.centered = false,
  });

  @override
  _CircleSwitcherState createState() => _CircleSwitcherState();
}

class _CircleSwitcherState extends State<CircleSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          widget.centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: 140,
            padding: EdgeInsets.only(bottom: 14.0, top: 6.0),
            child: widget.centered
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [for (CircleItem item in widget.items) item],
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: [for (CircleItem item in widget.items) item],
                  ),
          ),
        ),
      ],
    );
  }
}
