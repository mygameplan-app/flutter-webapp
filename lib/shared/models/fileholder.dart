import 'dart:html' as html;

class FileHolder {
  html.File file;
  String name;

  FileHolder(html.File file, String name) {
    this.file = file;
    this.name = name;
  }
}
