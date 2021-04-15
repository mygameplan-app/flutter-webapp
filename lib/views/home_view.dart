import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/message_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/customer.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/drawer.dart';
import 'package:jdarwish_dashboard_web/views/pages/goals_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/profile_page.dart';
import 'package:jdarwish_dashboard_web/views/tabs/lifestyle_tab.dart';
import 'package:jdarwish_dashboard_web/views/tabs/nutrition_tab.dart';
import 'package:jdarwish_dashboard_web/views/tabs/store_tab.dart';
import 'package:jdarwish_dashboard_web/views/tabs/training_tab.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int navIndex = 0;

  TabController _tabController;

  @override
  void initState() {
    if (UserBloc().fbUser == null || AppBloc().adminId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/', predicate: (route) => false);
      });
    }

    _tabController = TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBloc().backgroundUrl != null
            ? Image.network(
                AppBloc().backgroundUrl,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              )
            : Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
        Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0.6),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: 28.0,
            currentIndex: navIndex,
            unselectedItemColor: Colors.white.withOpacity(0.4),
            onTap: (i) {
              setState(() => navIndex = i);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(LineAwesomeIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(LineAwesomeIcons.bar_chart_o),
                label: 'Goals',
              ),
              BottomNavigationBarItem(
                icon: Icon(LineAwesomeIcons.user),
                label: 'Account',
              ),
            ],
          ),
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 24,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: AppBloc().logoUrl != null
                ? Image.network(
                    AppBloc().logoUrl,
                    height: 56,
                  )
                : Container(),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: UserBloc().isAdmin
                ? Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : Container(),
            actions: [
              Container(
                  margin: EdgeInsets.only(right: 12), child: _messagesIcon()),
            ],
          ),
          drawer: AdminDrawer(),
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: _getBodyWidget(navIndex),
          ),
        ),
      ],
    );
  }

  Widget _getBodyWidget(int index) {
    if (index == 0) {
      return Column(
        children: [
          _tabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TrainingTab(),
                NutritionTab(),
                LifestyleTab(),
                StoreTab(),
                // StoreTab(),
              ],
            ),
          ),
        ],
      );
    }
    if (index == 1) {
      return GoalsPage();
    }
    if (index == 2) {
      return ProfilePage();
    }
  }

  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      labelPadding: EdgeInsets.all(0.0),
      indicator: BoxDecoration(
        border: Border(top: BorderSide(width: 3.0, color: Colors.white)),
      ),
      tabs: [
        _tabItem('Workouts'),
        _tabItem('Nutrition'),
        _tabItem('Lifestyle'),
        _tabItem('Store'),
      ],
    );
  }

  Widget _tabItem(String title) {
    return Tab(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withAlpha(50),
                    width: 1.0,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messagesIcon() {
    if (UserBloc().isAdmin) {
      return StreamBuilder<List<Customer>>(
          stream: MessageBloc().customerStream,
          initialData: MessageBloc().users,
          builder: (context, snapshot) {
            int unreadMessages = 0;
            if (snapshot.hasData) {
              for (Customer c in MessageBloc().users) {
                print(c.unread);
                if (c.unread != null && c.unread > 0) {
                  print(c.email);
                  unreadMessages += c.unread;
                }
              }
            }
            return IconButton(
                iconSize: 32.0,
                icon: Badge(
                  showBadge: unreadMessages > 0,
                  badgeContent: Text(unreadMessages.toString()),
                  badgeColor: Colors.blue,
                  animationType: BadgeAnimationType.fade,
                  child: Icon(LineAwesomeIcons.comments),
                ),
                onPressed: () => Get.toNamed('/messages'));
          });
    } else {
      return StreamBuilder<int>(
          stream: MessageBloc().unreadStream,
          initialData: MessageBloc().unread,
          builder: (context, snapshot) {
            int unreadMessages = 0;
            if (snapshot.hasData) {
              unreadMessages = MessageBloc().unread;
            }
            return IconButton(
              iconSize: 32.0,
              icon: Badge(
                showBadge: unreadMessages > 0,
                badgeContent: Text(unreadMessages.toString()),
                badgeColor: Colors.blue,
                animationType: BadgeAnimationType.fade,
                child: Icon(LineAwesomeIcons.comments),
              ),
              onPressed: () => Get.toNamed('/messages'),
            );
          });
    }
  }
}
