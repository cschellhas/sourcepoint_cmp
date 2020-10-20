import Flutter
import UIKit

public class SwiftSourcepointCmpPlugin: NSObject, FlutterPlugin {
    //Channel Method Name
    public static func register(with registrar: FlutterPluginRegistrar) {

        let interstitialChannel = FlutterMethodChannel(name: "sourcepoint_cmp", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(SourcepointCmp(with: registrar, channel: interstitialChannel) as FlutterPlugin, channel: interstitialChannel)

    }
    
}
