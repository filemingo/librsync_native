import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librsync_native/librsync_native_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelLibrsyncNative platform = MethodChannelLibrsyncNative();
  const MethodChannel channel = MethodChannel('librsync_native');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        expect(methodCall.method, "computeDelta");
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    await platform.computeDelta("", "", (data) => null);
  });
}
