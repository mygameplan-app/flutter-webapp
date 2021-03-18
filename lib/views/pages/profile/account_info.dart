import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Information"),
      ),
      body: Container(
        padding: EdgeInsets.all(24.0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.white, height: 1.5),
            children: [
              TextSpan(text: "Your account email is "),
              TextSpan(
                  text: UserBloc().fbUser.email,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text:
                    "\n\nManaging your subscription is not supported in the mobile app. "
                    "You will need to sign into the web portal to view or manage your subscription.\n\n"
                    "For support, please contact us at matthew@jdarwish_dashboard_web.app.",
              )
            ],
          ),
        ),
      ),
    );
  }
}
