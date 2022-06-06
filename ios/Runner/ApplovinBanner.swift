import Flutter
import UIKit
import AppLovinSDK

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return ApplovinBanner(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }
}

class ApplovinBanner: NSObject, FlutterPlatformView {
    private var _view: UIView
    var adView: MAAdView!

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger?) {
        _view = UIView()
        super.init()
        // iOS views can be created here
        createNativeView(view:_view)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView){
        adView = MAAdView(adUnitIdentifier: "15e7efce98556126", adFormat: MAAdFormat.mrec)
        // adView.delegate = self
    
        // MREC width and height are 300 and 250 respectively, on iPhone and iPad
        let height: CGFloat = 250
        let width: CGFloat = 300
        adView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    
        // Center the MREC
        adView.center.x = _view.center.x
    
        // Set background or background color for MREC ads to be fully functional
        _view.addSubview(adView)    

        // Load the first ad
        adView.loadAd()
    }
}
