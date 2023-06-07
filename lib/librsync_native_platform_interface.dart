import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'librsync_native_method_channel.dart';

abstract class LibrsyncNativePlatform extends PlatformInterface {
  /// Constructs a LibrsyncNativePlatform.
  LibrsyncNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static LibrsyncNativePlatform _instance = MethodChannelLibrsyncNative();

  /// The default instance of [LibrsyncNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelLibrsyncNative].
  static LibrsyncNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LibrsyncNativePlatform] when
  /// they register themselves.
  static set instance(LibrsyncNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> computeDelta(
      String signatureStr, String targetPath, Function(Uint8List data) onData) {
    throw UnimplementedError('computeDelta() has not been implemented.');
  }
}
