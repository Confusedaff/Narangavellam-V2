import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompress {
  static Future<File?> compressFile(File file, {int quality = 80}) async {
    final targetPath = '${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: quality,
    );

    if (result == null) return null;

    return File(result.path);
  }
}
