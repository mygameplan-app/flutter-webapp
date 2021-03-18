import 'dart:html';
import 'dart:io';

import 'package:firebase/firebase.dart' as fb;
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import 'package:image_picker_web/image_picker_web.dart';
import 'dart:async';
import 'dart:html' as html;

class ExerciseVideoBloc {
  static final ExerciseVideoBloc _singleton = ExerciseVideoBloc._internal();
  factory ExerciseVideoBloc() {
    return _singleton;
  }
  ExerciseVideoBloc._internal();

  Future<String> uploadVideo() async {
    // HTML input element
    if (GetPlatform.isDesktop) {
      html.File file1 =
          await ImagePickerWeb.getVideo(outputType: VideoType.file);
      name = file1.name;
      file = file1;
      return name != null || name != "" ? name : "";
    } else {
      /* var file2 = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['MOV', 'MP4'],
          allowMultiple: false);
      if (file2 != null) {
        mobileFile = file2.files.single;
        name = file2.files.single.name;
        return name;
      } */
      final completer = Completer<List<String>>();
      final html.InputElement input = html.document.createElement('input');
      input
        ..type = 'file'
        ..multiple = false;

      input.click();
      // onChange doesn't work on mobile safari
      input.addEventListener('change', (e) async {
        final List<html.File> files = input.files;
        mobileFile = files.first;
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
      final List<String> videos = await completer.future;

      //imageFileHolder.image = material.Image.network(images.first);
      input.remove();

      return videos.first;
    }
  }

  Future<String> uploadToFirebase() async {
    if (GetPlatform.isDesktop) {
      final filePath = 'videos/${DateTime.now()}.mp4';
      print(filePath);
      if (file == null) {
        return "";
      } else {
        fb.StorageReference reference = fb
            .storage()
            .refFromURL('gs://mygameplan-4de84.appspot.com')
            .child(filePath);

        fb.UploadTaskSnapshot uploadTaskSnapshot =
            await reference.put(file).future;

        var videoUri = await uploadTaskSnapshot.ref.getDownloadURL();

        var url = videoUri.toString();

        return url;
      }
    } else {
      final filePath = 'videos/${DateTime.now()}.mp4';
      print(filePath);
      if (mobileFile == null) {
        return "";
      } else {
        fb.StorageReference reference = fb
            .storage()
            .refFromURL('gs://mygameplan-4de84.appspot.com')
            .child(filePath);

        fb.UploadTaskSnapshot uploadTaskSnapshot =
            await reference.put(mobileFile).future;

        var videoUri = await uploadTaskSnapshot.ref.getDownloadURL();

        var url = videoUri.toString();

        return url;
      }
    }
  }

  String name;
  html.File file;
  html.File mobileFile;
}
