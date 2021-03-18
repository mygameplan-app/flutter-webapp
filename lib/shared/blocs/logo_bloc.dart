import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:firebase/firebase.dart' as fb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:html' as html;
import 'package:image_whisperer/image_whisperer.dart';
import 'package:jdarwish_dashboard_web/shared/models/fileholder.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';
import 'package:jdarwish_dashboard_web/shared/utils/ImageUpload.dart';

class LogoBloc {
  static final LogoBloc _singleton = LogoBloc._internal();
  factory LogoBloc() {
    return _singleton;
  }
  LogoBloc._internal();

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

      var url = imageUri.toString();

      return url;
    }
  }

  Image image;

  html.File file;
  File file2;
}
