import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_program.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/lifestyle_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:uuid/uuid.dart';

class LifestyleAdmin extends StatefulWidget {
  final LifestyleProgram lifestyleProgram;
  final LifestyleDay lifestyleDay;

  LifestyleAdmin({
    this.lifestyleDay,
    this.lifestyleProgram,
  });

  _LifestyleAdminState createState() => _LifestyleAdminState();
}

class _LifestyleAdminState extends State<LifestyleAdmin> {
  List<LifestyleItem> lifestyleItems = [];
  bool isReordering = false;

  StreamBuilder lifestyleFetcher() {
    void doPopUp(Functions result, LifestyleItem lifestyleItem) async {
      print(lifestyleItem.id);

      switch (result) {
        case Functions.delete:
          await FirebaseFirestore.instance
              .collection('apps')
              .doc(appId)
              .collection('lifestyle')
              .doc(widget.lifestyleProgram.id)
              .collection('days')
              .doc("defaultDay")
              .collection('items')
              .doc(lifestyleItem.id)
              .delete();

          return;
        case Functions.edit:
          LifestylePopup lifestylePopup = LifestylePopup(
            popUpFunctions: PopUpFunctions.edit,
            count: lifestyleItems.length,
            item: lifestyleItem,
            lifestyleDay: widget.lifestyleDay,
            lifestyleProgram: widget.lifestyleProgram,
          );
          await Navigator.push(
              context, TransparentRoute(builder: (context) => lifestylePopup));

          return;
        case Functions.duplicate:
          LifestyleItem newItem = lifestyleItem;
          newItem.id = Uuid().v1();
          newItem.order = lifestyleItems != null ? lifestyleItems.length : 0;
          LifestyleBloc().addLifestyleItem(
              widget.lifestyleProgram.id, widget.lifestyleDay.id, newItem);
          return;
        case Functions.reorder:
          setState(() {
            isReordering = true;
          });
          return;
        default:
          return;
      }
    }

    Column getListView() {
      List<Widget> containers = [];
      int counter = 0;
      for (LifestyleItem item in lifestyleItems) {
        containers.add(
          Container(
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white10,
                border: Border(
                    top: counter == 0
                        ? BorderSide(color: Colors.grey, width: 1)
                        : BorderSide(color: Colors.transparent, width: 0),
                    bottom: BorderSide(color: Colors.grey, width: 1))),
            child: ListTile(
              title: Text(item.title),
              subtitle: Text(item.subtitle ?? ""),
              leading: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (Functions result) {
                  doPopUp(result, item);
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Functions>>[
                  const PopupMenuItem<Functions>(
                    value: Functions.edit,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<Functions>(
                    value: Functions.duplicate,
                    child: Text('Duplicate'),
                  ),
                  const PopupMenuItem<Functions>(
                    value: Functions.delete,
                    child: Text('Delete'),
                  ),
                  const PopupMenuItem<Functions>(
                      value: Functions.reorder, child: Text('Reorder'))
                ],
              ),
            ),
          ),
        );
        counter += 1;
      }
      return Column(children: containers);
    }

    Query query = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(widget.lifestyleProgram.id)
        .collection('days')
        .doc("defaultDay")
        .collection('items')
        .orderBy('order');
    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, stream) {
        if (stream.hasData == false) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)));
        } else if (stream.hasError) {
          return Center(child: Text(stream.error.toString()));
        } else if (stream.hasData == true) {
          QuerySnapshot querySnapshot = stream.data;
          lifestyleItems = querySnapshot.docs
              .map<LifestyleItem>(
                  (item) => LifestyleItem.fromJson(item.data())..id = item.id)
              .toList();

          return Column(children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              height: 100,
              width: 250,
              child: LongButton(
                text: 'Add Lifestyle Item',
                icon: Icons.add,
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () {
                  LifestylePopup lifestylePopup = LifestylePopup(
                    lifestyleProgram: widget.lifestyleProgram,
                    lifestyleDay: widget.lifestyleDay,
                    count: lifestyleItems.length,
                    popUpFunctions: PopUpFunctions.add,
                  );
                  Navigator.push(context,
                      TransparentRoute(builder: (context) => lifestylePopup));
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: getListView(),
            ),
          ]);
        } else {
          return Container();
        }
      },
    );
  }

  Widget reorderable() {
    ListTile getlistTile(LifestyleItem item, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Text(item.title),
        trailing: Icon(
          Icons.reorder,
          size: 30,
          color: Colors.white,
        ),
      );
    }

    return ReorderableFirebaseList(
        collection: FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('lifestyle')
            .doc(widget.lifestyleProgram.id)
            .collection('days')
            .doc("defaultDay")
            .collection('items'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(LifestyleItem.fromJson(doc.data()), index);
        },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lifestyle Items'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          isReordering
              ? TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    setState(() {
                      isReordering = false;
                    });
                  },
                )
              : Container()
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        Image.network(
          AppBloc().backgroundUrl,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.3),
          colorBlendMode: BlendMode.darken,
        ),
        isReordering
            ? SafeArea(child: reorderable())
            : ListView(
                children: [div1(), lifestyleFetcher()],
              )
      ]),
    );
  }

  Widget div1() {
    return Divider(
      color: Colors.grey,
      height: 1,
      thickness: 1,
    );
  }
}
