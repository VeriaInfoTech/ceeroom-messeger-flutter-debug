import UIKit
import CallKit
import AVFAudio
import WebRTC
import PushKit
import Flutter
import flutter_callkit_incoming
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate ,CXProviderDelegate {

    var callKitProvider: CXProvider?
    var callController: CXCallController?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)

    print("START");

    // Flutter method channel for wakelock (optional)
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let wakelockChannel = FlutterMethodChannel(name: "wakelock_channel", binaryMessenger: controller.binaryMessenger)
    wakelockChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "toggle" {
          guard let enable = call.arguments as? Bool else {
              result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
              return
          }
          UIApplication.shared.isIdleTimerDisabled = enable
          result(nil)
      } else {
          result(FlutterMethodNotImplemented)
      }
    }

     let config = CXProviderConfiguration(localizedName: "Your App Name")
    config.iconTemplateImageData = UIImage(named: "AppIcon")?.pngData()
    config.ringtoneSound = "ringtone.caf"
    config.includesCallsInRecents = false

    callKitProvider = CXProvider(configuration: config)
    callKitProvider?.setDelegate(self, queue: nil)

    callController = CXCallController()


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Implement CallKitIncomingAppDelegate methods

//   func didDisplayIncomingCall(_ uuid: UUID, completion: @escaping (CXCallAction) -> Void) {
//     // Update UI in your Flutter app to notify user about incoming call (use Flutter method channels)
//     completion(.answer) // Assuming you want to automatically answer the call
//   }
//
//   func didAcceptCall(_ uuid: UUID) {
//     // Initiate WebRTC call in your Flutter app (refer to flutter_callkit_incoming documentation)
//   }
//
//   func didDeclineCall(_ uuid: UUID) {
//     // Send a call declined notification to the other party (refer to your server-side implementation)
//   }
//
//   func didTimeoutCall(_ uuid: UUID) {
//     // Handle missed call scenario (e.g., display notification in Flutter app)
//   }




    // MARK: - CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        // Handle provider reset if needed
        print("appDelegate => CXProvider");
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Handle the start call action
        print("appDelegate => CXStartCallAction");
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Handle the call answer action
        // This is where you should initialize your WebRTC connection
        print("appDelegate => CXAnswerCallAction");
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Handle the call end action
        print("appDelegate => CXEndCallAction");
        action.fulfill()
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Configure audio session for the call
        // Typically, you would start your WebRTC audio here
        print("appDelegate => didActivate");
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // Handle deactivation of audio session
        // Typically, you would stop your WebRTC audio here
        print("appDelegate => didDeactivate");
    }
}
