import 'dart:typed_data';

import 'librsync_native_platform_interface.dart';

class LibrsyncNative {
  Future<void> computeDelta(String signatureStr, String targetPath,
      Function(Uint8List bytes) onData) async {
    return LibrsyncNativePlatform.instance
        .computeDelta(signatureStr, targetPath, onData);
  }
}
