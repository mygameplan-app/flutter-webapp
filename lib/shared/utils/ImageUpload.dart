import 'dart:async';
import 'dart:html' as html;
import 'dart:html';

import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_whisperer/image_whisperer.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';

class ImageUploader {
  static Future<ImageFileHolder> _getMobileImage() async {
    ImageFileHolder imageFileHolder = ImageFileHolder();
    final completer = Completer<List<String>>();
    final html.InputElement input = html.document.createElement('input');
    input
      ..type = 'file'
      ..multiple = false
      ..accept = 'image/*';
    input.click();
    // onChange doesn't work on mobile safari
    input.addEventListener('change', (e) async {
      final List<html.File> files = input.files;
      imageFileHolder.file = files.first;
      Iterable<Future<String>> resultsFutures = files.map((file3) {
        final reader = FileReader();
        reader.readAsDataUrl(file3);
        reader.onError.listen((error) => completer.completeError(error));
        return reader.onLoad.first.then((_) => reader.result as String);
      });
      final results = await Future.wait(resultsFutures);
      completer.complete(results);
    });
    // need to append on mobile safari
    html.document.body.append(input);
    // input.click(); can be here
    final List<String> images = await completer.future;

    imageFileHolder.image = material.Image.network(images.first);
    input.remove();

    return imageFileHolder;
  }

  static Future<ImageFileHolder> _getDesktopImage() {
    final completer = Completer<ImageFileHolder>();
    ImageFileHolder imageFileHolder = ImageFileHolder();
    html.InputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*';

    uploadInput.click();
    uploadInput.onChange.listen((event) {
      final file1 = uploadInput.files.first;
      print(file1.name);

      final reader = html.FileReader();
      reader.readAsDataUrl(file1);
      reader.onLoadEnd.listen((event) {
        BlobImage blobImage = new BlobImage(file1, name: file1.name);

        imageFileHolder.image = Image.network(blobImage.url);
        print(imageFileHolder.image.width);
        imageFileHolder.file = file1;
        print(imageFileHolder.file.name);
        return completer.complete(imageFileHolder);
      });
    });

    return completer.future;
  }

  static Future<ImageFileHolder> uploadImageToDevice() async {
    if (Get.context.isPhone || Get.context.isTablet) {
      return await _getMobileImage();
    } else {
      return await _getDesktopImage();
    }
  }

  static Future<String> uploadFileToCloudStorage(File file) async {
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
              cacheControl: 'public,max-age=3600,s-maxage=3600',
            ),
          )
          .future;

      var imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
      return imageUri.toString();
    }
  }
}
