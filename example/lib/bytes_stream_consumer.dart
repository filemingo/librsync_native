import 'dart:async';
import 'dart:typed_data';

import 'package:librsync/librsync.dart';

class BytesStreamConsumer implements Writer, StreamConsumer<List<int>> {
  final BytesBuilder builder = BytesBuilder();

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      builder.add(chunk);
    }
  }

  @override
  Future<void> close() {
    // No additional action required for BytesBuilder.
    return Future.value();
  }

  Uint8List toUint8List() {
    return builder.toBytes();
  }

  @override
  Future<void> write(List<int> bytes) async {
    builder.add(bytes);
  }
}
