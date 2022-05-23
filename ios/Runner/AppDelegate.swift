import FBSDKCoreKit
import FBSDKShareKit
import Flutter
import Photos
import TikTokOpenSDK
import UIKit

@UIApplicationMain @objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
  {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "io.socialbook/cartoonizer", binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method.elementsEqual("ShareFacebook") {
        if let dict = call.arguments as? [String: Any] {
          let fileType = dict["fileType"] as? String
          let fileURL = dict["fileURL"] as? String
          self.shareFacebook(fileType: fileType ?? "image", fileURL: URL.init(string: fileURL ?? "")!)
        }
      } else if call.method.elementsEqual("AppInstall") {
        if let dict = call.arguments as? [String: Any] {
          let appURLScheme = String.init(format: "%@://", dict["path"] as? String ?? "")
          guard let appURL = URL(string: appURLScheme) else { return }
          if UIApplication.shared.canOpenURL(appURL) { result(true) } else { result(false) }
        }
      } else if call.method.elementsEqual("OpenTiktok") {
        let scopes = "user.info.basic,video.list,video.upload"
        let scopesSet = NSOrderedSet(array: [scopes])
        let request = TikTokOpenSDKAuthRequest()
        request.permissions = scopesSet

        request.send(
          controller,
          completion: { resp -> Void in
            if resp.errCode.rawValue == 0 {
              let responseCode = resp.code
              result(responseCode)  // replace this baseURLstring with your own wrapper API
            } else {
              // TODO: oauth failure
            }
          })
      }
    })
      
    GeneratedPluginRegistrant.register(with:  self)
    TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

    let registrar = self.registrar(forPlugin: "io.socialbook/applovin_banner_view")!
    let factory = FLNativeViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "io.socialbook/applovin_banner_view")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    if TikTokOpenSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: nil, annotation: "") { return true }
    return super.application(app, open: url, options: options)
  }

  override func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    if TikTokOpenSDKApplicationDelegate.sharedInstance().application(
      application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    {
      return true
    }
    return false
  }

  override func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: nil, annotation: "") { return true }
    return false
  }

  func shareFacebook(fileType: String, fileURL: URL) {
    if fileType == "image" {
      let photo = SharePhoto(image: UIImage(contentsOfFile: fileURL.path)!, userGenerated: true)
      let content = SharePhotoContent()
      content.photos = [photo]
      let dialog = ShareDialog(viewController: self.window?.rootViewController, content: content, delegate: self as? SharingDelegate)
      dialog.mode = .native
      dialog.show()
    } else {
      let video: ShareVideo
      if #available(iOS 11, *) {
        guard let videoAsset = fileURL as? PHAsset else { return }
        video = ShareVideo(videoAsset: videoAsset)
      } else {
        video = ShareVideo(videoURL: fileURL)
      }
      let content = ShareVideoContent()
      content.video = video
      let dialog = ShareDialog(viewController: self.window?.rootViewController, content: content, delegate: self as? SharingDelegate)
      dialog.mode = .native
      dialog.show()
    }
  }

  func createAssetURL(url: URL, completion: @escaping (String) -> Void) {
    let photoLibrary = PHPhotoLibrary.shared()
    var videoAssetPlaceholder: PHObjectPlaceholder!
    photoLibrary.performChanges(
      {
        let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        videoAssetPlaceholder = request!.placeholderForCreatedAsset
      },
      completionHandler: { success, error in
        if success {
          let localID = NSString(string: videoAssetPlaceholder.localIdentifier)
          let assetID = localID.replacingOccurrences(of: "/.*", with: "", options: NSString.CompareOptions.regularExpression, range: NSRange())
          let ext = "mp4"
          let assetURLStr = "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
          completion(assetURLStr)
        }
      })
  }
}
