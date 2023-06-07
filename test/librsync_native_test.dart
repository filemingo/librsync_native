import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:librsync_native/librsync_native.dart';
import 'package:librsync_native/librsync_native_platform_interface.dart';
import 'package:librsync_native/librsync_native_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

final messages = <List<int>>[
  utf8.encode("Hello"),
  utf8.encode(" "),
  utf8.encode("World")
];

class MockLibrsyncNativePlatform
    with MockPlatformInterfaceMixin
    implements LibrsyncNativePlatform {
  @override
  Future<void> computeDelta(String signatureStr, String targetPath,
      Function(Uint8List data) onData) async {
    for (var message in messages) {
      onData(Uint8List.fromList(message));
    }
  }
}

void main() {
  final LibrsyncNativePlatform initialPlatform =
      LibrsyncNativePlatform.instance;

  test('$MethodChannelLibrsyncNative is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLibrsyncNative>());
  });

  test('computeDelta', () async {
    LibrsyncNative librsyncNativePlugin = LibrsyncNative();
    MockLibrsyncNativePlatform fakePlatform = MockLibrsyncNativePlatform();
    LibrsyncNativePlatform.instance = fakePlatform;

    int idx = 0;

    onData(Uint8List bytes) {
      final expected = messages[idx];
      expect(bytes, expected);
    }

    await librsyncNativePlugin.computeDelta("", "", onData);
  });
}
