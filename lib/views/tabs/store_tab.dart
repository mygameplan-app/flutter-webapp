import 'dart:html';

import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_categories_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';
import 'package:jdarwish_dashboard_web/shared/models/product_category.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_item.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_switcher.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreTab extends StatefulWidget {
  @override
  _StoreTabState createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  List<ProductCategory> productCategories = [];
  List<Product> products = [];
  ProductCategory selectedProductCategory;
  ProductCategoriesBloc bloc = ProductCategoriesBloc();

  @override
  void initState() {
    productCategories = bloc.categories;
    selectedProductCategory =
        productCategories.isNotEmpty ? productCategories[0] : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (productCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 32.0,
            ),
            SizedBox(height: 20),
            Container(
              width: 240.0,
              child: Text(
                "Check back soon for products.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    productCategories.sort((a, b) => a.order.compareTo(b.order));
    selectedProductCategory?.products
        ?.sort((a, b) => a.order.compareTo(b.order));
    return Column(
      children: [
        CircleSwitcher(
          items: [
            for (ProductCategory category in productCategories)
              CircleItem(
                title: category.name,
                color: category.themeColor,
                outlineColor: Colors.white,
                onTap: () {
                  setState(() => this.selectedProductCategory = category);
                  print(category.id);
                },
                selected: this.selectedProductCategory.id == category.id,
              )
          ],
        ),
        Divider(height: 2.0, thickness: 2.0),
        if (selectedProductCategory.products.length != 0)
          Expanded(
            child: _productsList(selectedProductCategory.products),
          ),
      ],
    );
  }

  Widget _productsList(List<Product> products1) {
    return Container(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: products1.length,
          itemBuilder: ((context, i) {
            return PhotoTile(
              title: selectedProductCategory.products[i].title ?? '',
              subtitle: selectedProductCategory.products[i].price ?? '',
              photoUrl: selectedProductCategory.products[i].imageUrl,
              onTap: () => launch(selectedProductCategory.products[i].link),
            );
          }),
        ),
      ),
    );
  }
}
