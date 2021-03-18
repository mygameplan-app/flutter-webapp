import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

navigate(BuildContext context, Widget widget) {
  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => widget));
}

navigateFresh(BuildContext context, Widget widget) {
  Navigator.of(context).pushAndRemoveUntil(
    CupertinoPageRoute(builder: (context) => widget),
    (route) => false,
  );
}
