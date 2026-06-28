import UIKit
import Flutter
import FirebaseCore
import AVFoundation
import Photos
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
    var audioPlayer: AVAudioPlayer?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // Microphone channel
        let channel = FlutterMethodChannel(name: "com.closerrr.app/microphone",
                                          binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "requestMicPermission" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.requestMicPermission(completion: { granted in
                result(granted)
            })
        })
        
        // Gallery channel
        let galleryChannel = FlutterMethodChannel(name: "com.closerrr.app/gallery",
                                                 binaryMessenger: controller.binaryMessenger)
        galleryChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "saveFileToGallery" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Path is required", details: nil))
                return
            }
            self?.saveFileToGallery(path: path, result: result)
        })

        // Ringtone Picker Channel for iOS
        let ringtoneChannel = FlutterMethodChannel(name: "com.closerrr.app/ringtone_picker",
                                                  binaryMessenger: controller.binaryMessenger)
        ringtoneChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "playSystemSound" {
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are required", details: nil))
                    return
                }
                if let soundName = args["soundName"] as? String {
                    if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "m4a") {
                        do {
                            // Stop existing player if any
                            self?.audioPlayer?.stop()
                            
                            // Initialize new player
                            let player = try AVAudioPlayer(contentsOf: soundURL)
                            self?.audioPlayer = player
                            player.prepareToPlay()
                            player.play()
                            result(nil)
                        } catch {
                            result(FlutterError(code: "PLAY_ERROR", message: "Failed to play sound: \(error.localizedDescription)", details: nil))
                        }
                    } else {
                        result(FlutterError(code: "NOT_FOUND", message: "Sound file \(soundName).m4a not found in bundle", details: nil))
                    }
                } else if let soundIDVal = args["soundID"] {
                    // Stop custom audio preview if any is playing
                    self?.audioPlayer?.stop()
                    self?.audioPlayer = nil
                    
                    let soundID: SystemSoundID
                    if let id = soundIDVal as? Int {
                        soundID = SystemSoundID(id)
                    } else if let id = soundIDVal as? Int32 {
                        soundID = SystemSoundID(id)
                    } else if let id = soundIDVal as? NSNumber {
                        soundID = SystemSoundID(id.uint32Value)
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "soundID must be an integer", details: nil))
                        return
                    }
                    AudioServicesPlaySystemSound(soundID)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "soundID or soundName is required", details: nil))
                }
            } else if call.method == "stopPreview" {
                self?.audioPlayer?.stop()
                self?.audioPlayer = nil
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func requestMicPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    private func saveFileToGallery(path: String, result: @escaping FlutterResult) {
        let fileURL = URL(fileURLWithPath: path)
        
        PHPhotoLibrary.requestAuthorization { status in
            let isAuthorized: Bool
            if #available(iOS 14.0, *) {
                isAuthorized = (status == .authorized || status == .limited)
            } else {
                isAuthorized = (status == .authorized)
            }
            
            guard isAuthorized else {
                result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library access denied", details: nil))
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                let ext = fileURL.pathExtension.lowercased()
                if ext == "mp4" || ext == "mov" || ext == "3gp" {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                } else {
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
                }
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        result(true)
                    } else {
                        result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription ?? "Unknown error saving to gallery", details: nil))
                    }
                }
            }
        }
    }
}