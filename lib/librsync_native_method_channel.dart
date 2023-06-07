import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nanoid/nanoid.dart';

import 'librsync_native_platform_interface.dart';

/// An implementation of [LibrsyncNativePlatform] that uses method channels.
class MethodChannelLibrsyncNative extends LibrsyncNativePlatform {
  static const base = 'librsync_native';

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('$base/call');

  @override
  Future<void> computeDelta(String signatureStr, String targetPath,
      Function(Uint8List data) onData) async {
    final id = nanoid(14);
    final streamID = "$base/events/$id";
    await methodChannel
        .invokeMethod("startStream", <String, dynamic>{"streamID": streamID});
    final eventChannel = EventChannel(streamID);
    eventChannel.receiveBroadcastStream().listen((event) {
      final map = event as Map<Object?, Object?>;
      final bytes = map["bytes"] as Uint8List;
      onData(bytes);
    });
    final promise = methodChannel.invokeMethod(
        "computeDelta", <String, dynamic>{
      "signatureStr": signatureStr,
      "targetPath": targetPath,
      "streamID": streamID
    });

    await promise;
  }
}
