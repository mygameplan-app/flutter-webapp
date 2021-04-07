import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';

import '../constants.dart';

class ProductBloc {
  static final ProductBloc _productbloc = ProductBloc._internal();

  factory ProductBloc() {
    return _productbloc;
  }

  ProductBloc._internal();

  void addProduct2toStore(Product product, String id) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('products')
        .doc(id)
        .collection('productList')
        .doc(product.id)
        .set(product.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editProduct2(Product product, String id) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('products')
        .doc(id)
        .collection('productList')
        .doc(product.id)
        .set(product.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }
}
