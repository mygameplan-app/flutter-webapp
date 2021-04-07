import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/image_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class ProductPopup extends StatefulWidget {
  final Product product;
  final int count;
  final PopUpFunctions popUpFunctions;
  final String id;

  ProductPopup(
      {this.product,
      @required this.count,
      @required this.popUpFunctions,
      @required this.id});

  MyProductPopup createState() => MyProductPopup();
}

class MyProductPopup extends State<ProductPopup> {
  String text = 'Only .png and .jpeg files allowed.';
  String price = "";
  String title = "";
  String description = "";
  bool isLoading = false;
  bool imageChanged = false;
  String link = "";
  Image image;
  final priceController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  ProductBloc product2bloc = ProductBloc();
  ImageUtils imageUtils = ImageUtils();

  double multiplier() {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      return 0.5;
    } else {
      return 0.8;
    }
  }

  _setUpFunction() {
    if (widget.popUpFunctions == PopUpFunctions.edit) {
      image = Image.network(widget.product.imageUrl);
      priceController.text = widget.product.price;
      titleController.text = widget.product.title;
      linkController.text = widget.product.link;
      descriptionController.text = widget.product.description;
    }
  }

  _loadingDialog(context) {
    showDialog(
        barrierDismissible: false,
        context: (context),
        builder: (
          BuildContext context,
        ) {
          return AlertDialog(
            backgroundColor: Colors.black26,
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                      Text(
                        'Loading...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  _onAlertWithCustomContextPassed(context) {
    Alert(
        closeFunction: () {
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        },
        style: AlertStyle(
            backgroundColor: Colors.black,
            titleStyle: TextStyle(color: Colors.white, fontSize: 20)),
        context: context,
        title: widget.popUpFunctions == PopUpFunctions.add
            ? "Add Product"
            : "Edit Product",
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            width: MediaQuery.of(context).size.width * multiplier(),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  controller: titleController,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Product Link',
                  ),
                  controller: linkController,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                  ),
                  controller: priceController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  controller: descriptionController,
                ),
                image != null
                    ? Container(
                        padding: EdgeInsets.only(top: 15),
                        child: image,
                        width: 150,
                        height: 150,
                      )
                    : Container(),
                Container(
                  height: 40,
                  width: 140,
                  padding: EdgeInsets.only(top: 15),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: MaterialButton(
                      color: Colors.grey,
                      onPressed: () async {
                        image = await imageUtils.uploadImage();
                        setState(() {
                          imageChanged = true;
                          image = image;
                        });
                      },
                      child: Text('Choose Image',
                          style: TextStyle(
                            color: Colors.white,
                          ))),
                ),
                Text(text,
                    style: TextStyle(
                      fontSize: 14,
                    ))
              ],
            ),
          );
        }),
        buttons: [
          DialogButton(
            color: Colors.red,
            onPressed: () async {
              if (image != null) {
                Navigator.pop(context);
                _loadingDialog(context);
                String imageURL = "";
                if (imageChanged) {
                  imageURL = await imageUtils.uploadToFirebase();
                }

                switch (widget.popUpFunctions) {
                  case PopUpFunctions.add:
                    String id = Uuid().v1();
                    var timeStamp = DateTime.now().toString();
                    int order = widget.count != null ? widget.count : 0;
                    Product product2 = Product(
                      title: title,
                      order: order,
                      description: description,
                      price: price,
                      link: link,
                      imageUrl: imageURL,
                      id: id,
                      timeStamp: timeStamp,
                    );
                    product2bloc.addProduct2toStore(product2, widget.id);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                  case PopUpFunctions.edit:
                    widget.product.description = descriptionController.text;
                    widget.product.title = titleController.text;
                    widget.product.price = priceController.text;
                    widget.product.link = linkController.text;
                    if (imageURL != "") {
                      widget.product.imageUrl = imageURL;
                    }
                    product2bloc.editProduct2(widget.product, widget.id);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                }
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  @override
  void initState() {
    linkController.addListener(_updateLatestValue);
    priceController.addListener(_updateLatestValue);
    descriptionController.addListener(_updateLatestValue);
    titleController.addListener(_updateLatestValue);
    Future.delayed(
        Duration.zero, () => _onAlertWithCustomContextPassed(context));
    _setUpFunction();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  _updateLatestValue() {
    title = titleController.text;
    link = linkController.text;
    description = descriptionController.text;
    price = priceController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0), //this is dependent on the import statment above
          child: Container(
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)))),
    ]);
  }
}

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    @required this.builder,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}
