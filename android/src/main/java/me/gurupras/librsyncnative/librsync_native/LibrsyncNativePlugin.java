package me.gurupras.librsyncnative.librsync_native;

import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import librsyncbridge.Stream;

/** LibrsyncNativePlugin */
public class LibrsyncNativePlugin implements FlutterPlugin, MethodCallHandler {
  static final String TAG = "librsync-native-java";
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private FlutterPluginBinding flutterPluginBinding;
  private Map<String, EventChannel.EventSink> eventSinkMap;
  private Map<String, EventChannel> eventChannelMap;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    GoLogger.init();
    this.flutterPluginBinding = flutterPluginBinding;
    eventSinkMap = new HashMap<>();
    eventChannelMap = new HashMap<>();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "librsync_native/call");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("startStream")) {
      Log.d(TAG, "Received startStream request");
      final String streamID = call.argument("streamID");
      EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), streamID);
      eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
          eventSinkMap.put(streamID, events);
          Log.d(TAG, "Received listener for EventChannel: " + streamID);
        }

        @Override
        public void onCancel(Object arguments) {
          eventSinkMap.remove(streamID);
        }
      });
      eventChannelMap.put(streamID, eventChannel);
      result.success(null);
    } else if (call.method.equals("computeDelta")) {
      String signatureStr = call.argument("signatureStr");
      String targetPath = call.argument("targetPath");
      final String streamID = call.argument("streamID");
      
      EventChannel eventChannel = eventChannelMap.get(streamID);
      librsyncbridge.Stream stream = new Stream() {
        @Override
        public void send(byte[] bytes, long l) {
          EventChannel.EventSink sink = eventSinkMap.get(streamID);
          Map<String, Object> eventData = new HashMap<>();
          eventData.put("bytes", bytes);
          Log.d(TAG, "Received bytes to send to eventChannel. streamID=" + streamID + " bytes=" + l);
          if (sink != null) {
            sink.success(eventData);
          }
        }
      };
      librsyncbridge.Librsyncbridge.computeDelta(signatureStr, targetPath, stream);
      // TODO: Maybe close the streams?
      eventChannelMap.remove(streamID);
      eventSinkMap.remove(streamID);
      result.success(null);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
