import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';
import 'package:jdarwish_dashboard_web/shared/models/product_category.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/exercise_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:uuid/uuid.dart';

class ProductDetailsAdmin extends StatefulWidget {
  final ProductCategory productCategory;

  ProductDetailsAdmin({@required this.productCategory});

  MyProductDetailsAdmin createState() => MyProductDetailsAdmin();
}

class MyProductDetailsAdmin extends State<ProductDetailsAdmin> {
  //Variables
  List<Product> products = [];
  bool isReordering = false;

  //ListView
  Column loadListView(QuerySnapshot querySnapshot, String id) {
    products = querySnapshot.docs
        .map<Product>(
            (product) => Product.fromJson(product.data())..id = product.id)
        .toList();

    List<Widget> containers = [];
    containers.add(Center(
      child: Container(
        height: 100,
        width: 270,
        child: LongButton(
          text: 'Add Products',
          icon: Icons.edit,
          color: Colors.red,
          textColor: Colors.white,
          onPressed: () {
            ProductPopup productPopup = ProductPopup(
                popUpFunctions: PopUpFunctions.add,
                count: products.length,
                id: widget.productCategory.id);
            Navigator.push(
                context, TransparentRoute(builder: (context) => productPopup));
          },
        ),
      ),
    ));
    int counter = 0;

    for (Product product in products) {
      containers.add(Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white10,
            border: Border(
                top: counter == 0
                    ? BorderSide(color: Colors.grey, width: 1)
                    : BorderSide(color: Colors.transparent, width: 0),
                bottom: BorderSide(color: Colors.grey, width: 1))),
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: SizedBox(
              width: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                      onSelected: (Functions result) {
                        doPopUp(result, product);
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
                  Image.network(
                    product.imageUrl,
                    height: 60,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          ),
          title: Text(product.title,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(product.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ));
      counter += 1;
    }
    return Column(children: containers);
  }

  void doPopUp(Functions result, Product product) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('products')
            .doc(widget.productCategory.id)
            .collection('productList')
            .doc(product.id)
            .delete();

        return;
      case Functions.edit:
        ProductPopup productPopup = ProductPopup(
            popUpFunctions: PopUpFunctions.edit,
            count: products.length,
            product: product,
            id: widget.productCategory.id);
        await Navigator.push(
            context, TransparentRoute5(builder: (context) => productPopup));

        return;
      case Functions.duplicate:
        Product newProduct = product;
        newProduct.id = Uuid().v1();
        newProduct.order = products != null ? products.length : 0;
        ProductBloc().addProduct2toStore(newProduct, widget.productCategory.id);
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

  //Product Stream
  StreamBuilder productFetcher() {
    Query query = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('products')
        .doc(widget.productCategory.id)
        .collection('productList')
        .orderBy('order');
    return StreamBuilder<QuerySnapshot>(
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
          if (querySnapshot.docs.length == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    LineAwesomeIcons.shopping_cart,
                    size: 38.0,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 240.0,
                    child: Text(
                      "No products added.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 270,
                    child: LongButton(
                      text: 'Add Products',
                      icon: Icons.edit,
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        ProductPopup productPopup = ProductPopup(
                            popUpFunctions: PopUpFunctions.add,
                            count: products.length,
                            id: widget.productCategory.id);
                        await Navigator.push(
                            context,
                            TransparentRoute(
                                builder: (context) => productPopup));
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
                width: 500,
                child: loadListView(querySnapshot, widget.productCategory.id));
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)));
        }
      },
    );
  }

  Widget reorderable() {
    ListTile getlistTile(Product product, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Image.network(
          product.imageUrl,
          height: 60,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(product.title),
        subtitle: Text(product.description),
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
            .collection('products')
            .doc(widget.productCategory.id)
            .collection('productList'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(Product.fromJson(doc.data())..id = doc.id, index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.productCategory.name}'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                children: [div1(), productFetcher()],
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
