import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:librsync_native/librsync_native.dart';
import 'package:librsync/librsync.dart';
import 'package:librsync/signature.dart';
import 'package:librsync/patch.dart';
import 'package:librsync_native_example/bytes_stream_consumer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'Unknown';
  final _librsyncNativePlugin = LibrsyncNative();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    const baseStr = 'Hello World';
    const targetStr = 'HollyWood';

    final tmp = Directory.systemTemp.path;

    final basePath = '$tmp/librsync_native-base.txt';
    final targetPath = '$tmp/librsync_native-target.txt';

    final baseFile = File(basePath);
    await baseFile.create();
    await baseFile.writeAsString(baseStr);

    final targetFile = File(targetPath);
    await targetFile.create();
    await targetFile.writeAsString(targetStr);

    final sigBuilder = BytesStreamConsumer();
    final sigSink = IOSink(sigBuilder);
    final sig = await createSignature(
        File(basePath).openRead(), sigSink, 512, 32, blake2SigMagic);

    final sigMap = <String, dynamic>{
      "SigType": sig.sigType,
      "BlockLen": sig.blockLen,
      "StrongLen": sig.strongLen,
      "StrongSigs": sig.strongSigs.map((e) => base64Encode(e)).toList(),
      "Weak2block":
          sig.weak2block.map((key, value) => MapEntry(key.toString(), value))
    };
    final sigStr = jsonEncode(sigMap);

    final deltaReadWriteStream = DeltaReadWriteStream();

    var result = '';
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    var promise =
        _librsyncNativePlugin.computeDelta(sigStr, targetPath, (bytes) {
      deltaReadWriteStream.write(bytes);
    });

    final output = BytesStreamConsumer();

    final patchPromise = patchWithBaseFile(
        await File(basePath).open(), deltaReadWriteStream, IOSink(output));
    try {
      await promise;
    } catch (e) {
      result = 'Exception while calling native: $e';
    }

    await patchPromise;

    result = utf8.decode(output.toUint8List());

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Result: $_result\n'),
        ),
      ),
    );
  }
}
