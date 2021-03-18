import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoTile extends StatelessWidget {
  final String photoUrl;
  final String title;
  final String subtitle;
  final double titleSize;
  final Widget trailing;
  final Function onTap;
  final Function onPhotoTap;

  PhotoTile(
      {@required this.photoUrl,
      @required this.title,
      this.subtitle,
      this.onTap,
      this.titleSize,
      this.onPhotoTap,
      this.trailing});

  /* void doPopUp(Functions result) async {
    switch (result) {
      case Functions.Delete:
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product2.id)
            .delete();
        
        return;
      case Functions.Edit:
        ProductPopup productPopup = ProductPopup(
          popUpFunctions: PopUpFunctions.Edit,
          product2: widget.product2,
        );
        await Navigator.push(
            context, TransparentRoute(builder: (context) => productPopup));
        
        return;
      case Functions.Duplicate:
        Product2Bloc product2bloc = Product2Bloc();
        Product2 newProduct2 = widget.product2;
        newProduct2.id = Uuid().v1();
        newProduct2.timeStamp = DateTime.now().toString();
        product2bloc.addProduct2toStore(newProduct2);
        return;
      default:
        return;
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    color: Colors.black.withOpacity(0.6),
                    child: InkWell(
                      onTap: onTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: onPhotoTap == null ? 4.0 : 12.0),
                            decoration: BoxDecoration(
                              border: onPhotoTap != null
                                  ? Border.all(width: 3, color: Colors.blue)
                                  : Border.fromBorderSide(BorderSide.none),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                onPhotoTap != null ? 100 : 0,
                              ),
                              child: InkWell(
                                onTap: onPhotoTap,
                                child: Image.network(
                                  photoUrl,
                                  width: onPhotoTap != null ? 95 : 140,
                                  height: 95,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(this.title.toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          titleSize != null ? titleSize : 22,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text(
                                this.subtitle ?? '',
                                style: Theme.of(context).textTheme.bodyText1,
                              )
                            ],
                          ),
                          Expanded(
                            child: trailing != null
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        Spacer(
                                          flex: 1,
                                        ),
                                        trailing
                                      ])
                                : Container(),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1),
                ],
              ),
            ),
          ],
        ),
        /* isAdmin
            ? Positioned(
                right: 0,
                top: 0,
                child: PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                  onSelected: (Functions result) {
                   // doPopUp(result);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<Functions>>[
                    const PopupMenuItem<Functions>(
                      value: Functions.Edit,
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<Functions>(
                      value: Functions.Duplicate,
                      child: Text('Duplicate'),
                    ),
                    const PopupMenuItem<Functions>(
                      value: Functions.Delete,
                      child: Text('Delete'),
                    ),
                  ],
                ))
            : Container() */
      ],
    );
  }
}
