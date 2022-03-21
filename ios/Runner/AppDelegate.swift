import UIKit
import Flutter
import Photos
import FBSDKCoreKit
import FBSDKShareKit
import TikTokOpenSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let methodChannel = FlutterMethodChannel(name: "io.socialbook/sharePhoto",
                                                binaryMessenger: controller.binaryMessenger)
      methodChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        
        
          if (call.method.elementsEqual("ShareInsta")) {
              if let dict = call.arguments as? [String:Any]{
                  let videoFilePath = dict["path"] as? String
                  let videoFileUrl: URL = URL(fileURLWithPath: videoFilePath ?? "")
                  var localId: String?
                  
                  PHPhotoLibrary.shared().performChanges({
                      let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoFileUrl)
                      localId = request?.placeholderForCreatedAsset?.localIdentifier
                  }, completionHandler: { success, error in
                      DispatchQueue.main.async {
                          guard error == nil else {
                              // handle error
                              return
                          }
                          guard let localId = localId else {
                              // highly unlikely that it'llbe nil,
                              // but you should handle this error just in case
                              return
                          }

                          let url = URL(string: "instagram://library?LocalIdentifier=\(localId)")!
                          guard UIApplication.shared.canOpenURL(url) else {
                              // handle this error
                              return
                          }
                          UIApplication.shared.open(url, options: [:], completionHandler: nil)
                      }
                  })
              }
              
          } else if (call.method.elementsEqual("ShareFacebook")) {
              if let dict = call.arguments as? [String:Any]{
                  let videoFilePath = dict["path"] as? String
                  self.shareFacebook(videoURLs: URL.init(string: videoFilePath ?? "")!)
              }
              
          } else if (call.method.elementsEqual("AppInstall")) {
              if let dict = call.arguments as? [String:Any]{
                  let appURLScheme = String.init(format: "%@://", dict["path"] as? String ?? "")
                  guard let appURL = URL(string: appURLScheme) else {
                                  return
                              }
                  if UIApplication.shared.canOpenURL(appURL)
                  {
                    result(true)
                  }
                  else {
                    result(false)
                  }
              }
              
          } else if (call.method.elementsEqual("OpenTiktok")) {
              let scopes = "user.info.basic,video.list,video.upload"
              let scopesSet = NSOrderedSet(array:[scopes])
              let request = TikTokOpenSDKAuthRequest()
              request.permissions = scopesSet
              
              request.send(self.window?.rootViewController ?? UIViewController(), completion: { resp -> Void in
                  let alertController = UIAlertController(title: String.init(format: "%d", resp.errCode.rawValue), message: String.init(format: "%@", resp.isSucceed ? "true" : "false"), preferredStyle: .actionSheet)
                  let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                      UIAlertAction in
                                  }
                
                  alertController.addAction(okAction)
                  self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                  if resp.errCode.rawValue == 0 {
                      let responseCode = resp.code
                      result(responseCode)
                      // replace this baseURLstring with your own wrapper API
                      /*let baseURlString = "https://open-api.tiktok.com/demoapp/callback/?code=\(responseCode)&client_key=\(clientKey)"
                      let url = NSURL(string: baseURlString)

                      /* STEP 3.b */
                      let session = URLSession(configuration: .default)
                      let urlRequest = NSMutableURLRequest(url: url! as URL)
                      let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) -> Void in
                           /* STEP 3.c */
                      }
                      task.resume()*/
                  } else {
                      let alertController = UIAlertController(title: String.init(format: "%d", resp.errCode.rawValue), message: String.init(format: "%@", resp.isSucceed ? "true" : "false"), preferredStyle: .actionSheet)
                      let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                          UIAlertAction in
                                      }
                    
                      alertController.addAction(okAction)
                      self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//                      let alertController = UIAlertController(title: "Failed", message: "Oops! Something went wrong", preferredStyle: .actionSheet)
//                      let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
//                                          UIAlertAction in
//                                      }
//
//                      alertController.addAction(okAction)
//                      self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                  }
                  
                 
              })
          }
          
      })
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

            guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                  let annotation = options[UIApplication.OpenURLOptionsKey.annotation] else {
                return false
            }

            if TikTokOpenSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation) {
                return true
            }
            return false
        }

    override func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
                return true
            }
            return false
        }

    override func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
            if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: nil, annotation: "") {
                return true
            }
            return false
        }
   
    func shareFacebook(videoURLs:URL) {
        let content: SharePhotoContent = SharePhotoContent()
                //let videoURLs = Bundle.main.url(forResource: "video", withExtension: "mp4")!
                createAssetURL(url: videoURLs) { url in
                    DispatchQueue.main.async {

                        let photo = SharePhoto(
                            imageURL: URL(string: url)!, isUserGenerated: true
                            )
                        content.photos = [photo]
                        let dialog = ShareDialog(viewController: self.window?.rootViewController, content: content, delegate: self as? SharingDelegate)
                               // dialog.mode = mode
                        //let shareDialog = ShareDialog()
                       // shareDialog.shareContent = content
                        dialog.mode = .native
    //                    shareDialog.delegate = self
                        dialog.show()
                    }
                  
                }
            }
    func createAssetURL(url: URL, completion: @escaping (String) -> Void) {
                let photoLibrary = PHPhotoLibrary.shared()
                var videoAssetPlaceholder:PHObjectPlaceholder!
                photoLibrary.performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    videoAssetPlaceholder = request!.placeholderForCreatedAsset
                },
                    completionHandler: { success, error in
                        if success {
                            let localID = NSString(string: videoAssetPlaceholder.localIdentifier)
                            let assetID = localID.replacingOccurrences(of: "/.*", with: "", options: NSString.CompareOptions.regularExpression, range: NSRange())
                            let ext = "mp4"
                            let assetURLStr =
                            "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"

                            completion(assetURLStr)
                        }
                })
            }
    
}
