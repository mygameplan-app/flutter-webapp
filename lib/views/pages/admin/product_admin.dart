import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_categories_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/product_category.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_category_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/product_detail_admin.dart';
import 'package:uuid/uuid.dart';

class ProductCategoriesAdmin extends StatefulWidget {
  MyProductCategoriesAdmin createState() => MyProductCategoriesAdmin();
}

class MyProductCategoriesAdmin extends State<ProductCategoriesAdmin> {
  List<ProductCategory> productCategories = [];
  bool isReordering = false;

  StreamBuilder categoriesFetcher() {
    void doPopUp(Functions result, ProductCategory productCategory) async {
      switch (result) {
        case Functions.delete:
          await FirebaseFirestore.instance
              .collection('apps')
              .doc(appId)
              .collection('products')
              .doc(productCategory.id)
              .delete();

          return;
        case Functions.edit:
          ProductCategoryPopup productCategoryPopup = ProductCategoryPopup(
            popUpFunctions: PopUpFunctions.edit,
            count: productCategories.length,
            productCategory: productCategory,
          );
          await Navigator.push(context,
              TransparentRoute(builder: (context) => productCategoryPopup));

          return;
        case Functions.duplicate:
          ProductCategory newProductCategory = productCategory;
          newProductCategory.id = Uuid().v1();
          newProductCategory.order =
              productCategories != null ? productCategories.length : 0;
          newProductCategory.timeStamp = DateTime.now().toString();
          ProductCategoriesBloc().addProductCategorytoStore(newProductCategory);
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
      for (ProductCategory productCategory in productCategories) {
        containers.add(Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white10,
              border: Border(
                  top: counter == 0
                      ? BorderSide(color: Colors.grey, width: 1)
                      : BorderSide(color: Colors.transparent, width: 0),
                  bottom: BorderSide(color: Colors.grey, width: 1))),
          child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetailsAdmin(
                              productCategory: productCategory,
                            )));
              },
              title: Text(productCategory.name),
              leading: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (Functions result) {
                  doPopUp(result, productCategory);
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
              trailing: Icon(
                Icons.navigate_next,
                size: 25,
                color: Colors.grey,
              )),
        ));
        counter += 1;
      }
      return Column(children: containers);
    }

    Query query = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('products')
        .orderBy('order');
    return StreamBuilder(
        stream: query.snapshots(),
        builder: (context, stream) {
          if (stream.hasData == false) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.white)));
          } else if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          } else if (stream.hasData == true) {
            QuerySnapshot querySnapshot = stream.data;
            productCategories = querySnapshot.docs
                .map<ProductCategory>((productcategory) =>
                    ProductCategory.fromJson(productcategory.data()))
                .toList();

            return Column(children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                height: 100,
                width: 250,
                child: LongButton(
                  text: 'Add Product Category',
                  icon: Icons.add,
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    ProductCategoryPopup productCategoryPopup =
                        ProductCategoryPopup(
                      count: productCategories.length,
                      popUpFunctions: PopUpFunctions.add,
                    );
                    Navigator.push(
                        context,
                        TransparentRoute(
                            builder: (context) => productCategoryPopup));
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
        });
  }

  Widget reorderable() {
    ListTile getlistTile(ProductCategory productCategory, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Text(productCategory.name),
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
            .collection('products'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(ProductCategory.fromJson(doc.data()), index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product Categories'),
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
                children: [div1(), categoriesFetcher()],
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
