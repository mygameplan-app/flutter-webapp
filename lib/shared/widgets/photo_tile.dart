import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';

class PhotoTile extends StatelessWidget {
  final String photoUrl;
  final String title;
  final String subtitle;
  final Function onTap;
  final Function onPhotoTap;

  PhotoTile({
    @required this.photoUrl,
    @required this.title,
    this.subtitle,
    this.onTap,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                              photoUrl ?? AppBloc().logoUrl,
                              width: onPhotoTap != null ? 95 : 140,
                              height: 95,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              this.title.toUpperCase(),
                              style: this.title.length > 16
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.headline4,
                            ),
                            SizedBox(height: 8),
                            Text(
                              this.subtitle ?? '',
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
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
    );
  }
}
