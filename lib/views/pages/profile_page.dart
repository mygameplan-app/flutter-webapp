import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/views/pages/profile/account_info.dart';

import '../login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          Divider(
            thickness: 1,
            height: 1,
            color: Colors.white.withAlpha(50),
          ),
          _header(),
          // Divider(),
          // ListTile(
          //   leading: Icon(LineAwesomeIcons.bell),
          //   title: Text('Push Notifications'),
          //   subtitle: Text(
          //     'Receive push notifications about goals and new features',
          //   ),
          //   trailing: PlatformSwitch(
          //     value: pushNotifications,
          //     onChanged: (p) => setState(() => pushNotifications = p),
          //   ),
          // ),
          Divider(),
          ListTile(
            leading: Icon(LineAwesomeIcons.user),
            title: Text('Account Information'),
            subtitle: Text(
              'View your account and billing information.',
            ),
            trailing: Icon(LineAwesomeIcons.angle_right),
            onTap: () => navigate(context, AccountInfo()),
          ),
          Divider(),
          ListTile(
            leading: Icon(LineAwesomeIcons.sign_out),
            title: Text('Log Out'),
            trailing: Icon(LineAwesomeIcons.angle_right),
            onTap: _logOut,
          ),
          Expanded(
            child: Container(),
          ),
          SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _header() {
    User user = UserBloc().fbUser;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                user.photoURL == null ? null : NetworkImage(user.photoURL),
            child: user.photoURL == null
                ? Icon(Icons.account_circle_outlined, size: 96)
                : null,
            radius: 48,
          ),
          SizedBox(width: 32.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? user.email,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 10.0),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  child: Text(
                    UserBloc().fbUser.uid == AppBloc().adminId
                        ? 'ADMIN'
                        : 'SUBSCRIBER',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _logOut() {
    showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: Text('Log out'),
          content: Text('You will be signed out of the app.'),
          actions: [
            PlatformDialogAction(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            PlatformDialogAction(
              child: Text('Log out'),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(builder: (context) => LoginView()),
                      (route) => false);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
