import Flutter
import UIKit

public class LibrsyncNativePlugin: NSObject, FlutterPlugin {
  var eventChannelMap = [String: FlutterEventChannel]()
  var eventSinkMap = [String: FlutterEventSink]()
  static var FlutterPluginRegistrar registrar?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "librsync_native/call", binaryMessenger: registrar.messenger())
    let instance = LibrsyncNativePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  // Define the Stream protocol
  protocol Stream {
    func send(_ bytes: [UInt8], _ length: Int)
  }

  // Define a Swift class that conforms to the Stream protocol
  class CallbackStream: Stream {
    let callback: ([Uint8]) -> Void

    init(callback: @escaping ([Uint8] -> Void)) {
      self.callback = callback
    }

    func send(_ bytes: [UInt8], _ length: Int) {
        callback(bytes)
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startStream":
      let arguments = call.arguments as? [String: Any]
      let streamID = arguments["streamID"] as? String
      let eventChannel = FlutterEventChannel(name: streamID, binaryMessenger: LibrsyncNativePlugin.registrar!.messenger())
      eventChannelMap[streamID] = eventChannel
      eventChannel.setStreamHandler(EventHandler(streamID: streamID), callback: { streamID, eventSink in
        eventSinkMap[streamID] = eventSink
      })
    case "computeDelta":
      let arguments = call.arguments as? [String: Any]
      let signatureStr = arguments["signatureStr"] as? String
      let targetPath = arguments["targetPath"] as? String
      let streamID = arguments["streamID"] as? String

      let callbackStream = CallbackStream(callback: { _ bytes: [Uint8] in 
        let result: [String: Any]()
        result["bytes"] = bytes
        let eventSink = eventSinkMap[streamID]
        eventSink.success(result)
      })


    default:
      result(FlutterMethodNotImplemented)
    }
  }

  
}

class EventHandler : FlutterStreamHandler {
  let streamID: String
  let callback: (String, FlutterEventSink) -> Void
  init(streamID: String, callback: @escaping (String, FlutterEventSink) -> Void) {
    self.streamID = streamID
    self.callback = callback
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    callback(self.streamID, eventSink)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }
}
