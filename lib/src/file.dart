import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> save_temp(String filename, Uint8List contents) async {
  String temp_dir = (await getTemporaryDirectory()).path;
  File file = new File(p.join(temp_dir, filename));
  await file.writeAsBytes(contents);
  return file;
}
