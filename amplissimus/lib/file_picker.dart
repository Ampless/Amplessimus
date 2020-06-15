import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

const MethodChannel _channel =
    MethodChannel('miguelruivo.flutter.plugins.filepicker');

class MethodChannelFilePicker {
  static const String _tag = 'MethodChannelFilePicker';
  static StreamSubscription _eventSubscription;

  Future getFiles(List<String> allowedExtensions) => _getPath(allowedExtensions);

  Future<dynamic> _getPath(List<String> allowedExtensions) async {
      _eventSubscription?.cancel();
      return _channel.invokeMethod('any', {
        'allowMultipleSelection': false,
        'allowedExtensions': allowedExtensions,
      });
  }
}

final MethodChannelFilePicker _instance = MethodChannelFilePicker();

class FilePicker {
  FilePicker._();

  static Future<File> getFile(List<String> allowedExtensions) async {
    final String filePath = await _instance.getFiles(allowedExtensions);
    return filePath != null ? File(filePath) : null;
  }
}
