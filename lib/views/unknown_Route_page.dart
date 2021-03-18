import 'package:flutter/material.dart';

class UnknownRoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      Icon(Icons.error,color: Colors.black,size: 35,),
      Text('404 Error: Unknown Page',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),)
    ],),);
  }
}
