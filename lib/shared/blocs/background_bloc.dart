import 'dart:html';
import 'dart:ui';

import 'package:firebase/firebase.dart' as fb;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:html' as html;
import 'package:image_whisperer/image_whisperer.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/image_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/fileholder.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';
import 'package:jdarwish_dashboard_web/shared/utils/ImageUpload.dart';

class BackgroundBloc {
  static final BackgroundBloc _singleton = BackgroundBloc._internal();
  factory BackgroundBloc() {
    return _singleton;
  }
  BackgroundBloc._internal();

  Future<Image> uploadImage() async {
    // HTML input element
    ImageUploader imageUploader = ImageUploader();
    if (Get.context.isPhone || Get.context.isTablet) {
      ImageFileHolder imageFileHolder = await imageUploader.getMobileImage();
      image = imageFileHolder.image;
      file = imageFileHolder.file;
      return image;
    } else {
      file = null;
      image = null;
      ImageFileHolder imageFileHolder = await imageUploader.getDesktopImage();
      image = imageFileHolder.image;
      file = imageFileHolder.file;
      return image;
    }
  }

  Future<String> uploadToFirebase() async {
    final filePath = 'images/${DateTime.now()}.png';
    //print(file.name);
    /*  if (Get.context.isPhone || Get.context.isTablet) {
      fb.StorageReference reference = fb
          .storage()
          .refFromURL('gs://mygameplan-4de84.appspot.com')
          .child(filePath);

      fb.UploadTaskSnapshot uploadTaskSnapshot = await reference
          .put(
              file2,
              fb.UploadMetadata(
                  contentType: 'image/png',
                  cacheControl: 'public,max-age=3600,s-maxage=3600'))
          .future;

      var imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
      print('imageUri');
      var url = imageUri.toString();
      print(url);
      return url;
    } else { */
    if (file == null) {
      return "";
    } else {
      fb.StorageReference reference = fb
          .storage()
          .refFromURL('gs://mygameplan-4de84.appspot.com')
          .child(filePath);

      fb.UploadTaskSnapshot uploadTaskSnapshot = await reference
          .put(
              file,
              fb.UploadMetadata(
                  contentType: 'image/png',
                  cacheControl: 'public,max-age=3600,s-maxage=3600'))
          .future;

      var imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
      print('imageUri');
      var url = imageUri.toString();
      print(url);
      return url;
    }
  }

  Image image;
  html.File file;
}
