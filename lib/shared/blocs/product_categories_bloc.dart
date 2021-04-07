import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';
import 'package:jdarwish_dashboard_web/shared/models/product_category.dart';

import '../constants.dart';

class ProductCategoriesBloc {
  static final ProductCategoriesBloc _singleton =
      ProductCategoriesBloc._internal();

  factory ProductCategoriesBloc() {
    return _singleton;
  }

  ProductCategoriesBloc._internal();

  List<ProductCategory> categories = [];

  Future<void> fetchCategories() async {
    categories = [];

    final categoriesDocs = await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('products')
        .get();
    List<Future> futures = [];
    for (var p in categoriesDocs.docs) {
      ProductCategory category = ProductCategory.fromJson(p.data());
      categories.add(category);
      print(category.themeColor);
      final productFuture =
          p.reference.collection('productList').get().then((productDocs) {
        for (var d in productDocs.docs) {
          Product product = Product.fromJson(d.data());
          print(product.price);
          category.products.add(product);
        }
      });
      futures.add(productFuture);
    }
    Future.wait(futures);
  }

  void addProductCategorytoStore(ProductCategory category) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('products')
        .doc(category.id)
        .set(category.toJson(), options);
  }

  void editProductCategory(ProductCategory category) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('products')
        .doc(category.id)
        .set(category.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }
}
