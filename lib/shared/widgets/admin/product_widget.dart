import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ProductWidget extends StatefulWidget {
  final Product product;
  final String categoryID;
  final int index;
  ProductWidget(
      {@required this.product,
      @required this.index,
      @required this.categoryID});
  MyProductWidget createState() => MyProductWidget();
}

class MyProductWidget extends State<ProductWidget> {
  void doPopUp(Functions result) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.categoryID)
            .collection('productList')
            .doc(widget.product.id)
            .delete();

        return;
      case Functions.edit:
        return;
      case Functions.duplicate:
        ProductBloc productbloc = ProductBloc();
        Product newProduct = widget.product;
        newProduct.id = Uuid().v1();
        newProduct.timeStamp = DateTime.now().toString();
        productbloc.addProduct2toStore(newProduct, widget.categoryID);
        return;
      default:
        return;
    }
  }

  void _launchURL() async => await canLaunch(widget.product.link)
      ? await launch(widget.product.link)
      : throw 'Could not launch ${widget.product.link}';

  @override
  void initState() {
    super.initState();
  }

  Widget wideProduct() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 20),
          height: 100,
          width: 500,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: InkWell(
            onTap: () {
              try {
                _launchURL();
              } catch (e) {
                print(e);
              }
            },
            child: Container(
              width: 400,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.product.imageUrl,
                      height: 100,
                      width: 150,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.title,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.product.description,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Buy From Website',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                  Icon(
                                    Icons.navigate_next,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                ],
                              )
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                widget.product.price,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 20,
              ),
              onSelected: (Functions result) {
                doPopUp(result);
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
              ],
            )),
      ],
    );
  }

  Widget smallProduct() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 20),
          height: 75,
          width: 300,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: InkWell(
            onTap: () {
              try {
                _launchURL();
              } catch (e) {
                print(e);
              }
            },
            child: Container(
              width: 300,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.product.imageUrl,
                      height: 75,
                      width: 100,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.title,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.product.description,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Buy From Website',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 8),
                                  ),
                                  Icon(
                                    Icons.navigate_next,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                ],
                              )
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                widget.product.price,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 20,
              ),
              onSelected: (Functions result) {
                doPopUp(result);
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
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return wideProduct();
      } else {
        return smallProduct();
      }
    });
  }
}
