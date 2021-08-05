//
//  SourcepointCmp.swift
//  sourcepoint_cmp
//
//  Created by Christoph Schellhas on 16.10.20.
//

import ConsentViewController

class SourcepointCmp : SwiftSourcepointCmpPlugin{
    private let channel: FlutterMethodChannel!
    private var cvc: GDPRConsentViewController!

    public init(with _: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.handle(call, result: result)
        })
    }


    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "load":
            load(call, result: result)
        case "showPM":
            showPM(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func load(_ call: FlutterMethodCall, result:@escaping FlutterResult){

        let argument = call.arguments as! Dictionary<String, Any>
        let accountId = argument["accountId"] as? Int ?? 22
        let propertyId = argument["propertyId"] as? Int ?? 7639
        let propertyName = argument["propertyName"] as? String ?? "tcfv2.mobile.webview"
        let PMId = argument["pmId"] as? String ?? "122058"

        cvc = GDPRConsentViewController(
                accountId: accountId,
                propertyId: propertyId,
                propertyName: try! GDPRPropertyName(propertyName),
                PMId: PMId,
                campaignEnv: .Public,
                consentDelegate: self
            )
        cvc.loadMessage();
    }

    private func showPM(_: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let cvc = cvc else {
            result(FlutterError(code: "program_error", message: "Please call load() method first.", details: nil))
            return
        }
        cvc.loadPrivacyManager();
    }

}

extension SourcepointCmp: GDPRConsentDelegate {
        func gdprConsentUIWillShow() {
            UIApplication.shared.keyWindow?.rootViewController?.present(cvc, animated: true, completion: nil)
            channel.invokeMethod("onConsentUIReady", arguments: nil)
        }

        func consentUIDidDisappear() {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            channel.invokeMethod("onConsentUIFinished", arguments: nil)
        }

        func onAction(_ action: GDPRAction) {
            var dict: [String: String] = [:]
            if (action.id != nil) {
                print("actionId: \(action.id!)")
                dict["actionType"] = action.id
            }
            channel.invokeMethod("onAction", arguments: dict)
        }

        func onConsentReady(gdprUUID: GDPRUUID, userConsent: GDPRUserConsent) {
            print("ConsentUUID: \(gdprUUID)")
            print("Consent String (euconsent): \(userConsent.euconsent)")
            userConsent.acceptedVendors.forEach { vendorId in print("Vendor: \(vendorId)") }
            userConsent.acceptedCategories.forEach { purposeId in print("Purpose: \(purposeId)") }

            // IAB Related Data
            print(UserDefaults.standard.dictionaryWithValues(forKeys: userConsent.tcfData.dictionaryValue?.keys.sorted() ?? []))
            var dict: [String: Any] = [:]
            dict["consentString"] = userConsent.euconsent
            dict["acceptedVendors"] = userConsent.acceptedVendors
            dict["acceptedCategories"] = userConsent.acceptedCategories
            dict["legIntCategories"] = userConsent.legitimateInterestCategories
            dict["specialFeatures"] = userConsent.specialFeatures
            channel.invokeMethod("onConsentReady", arguments: dict)
        }

        func onError(error: GDPRConsentViewControllerError?) {
            print("Error: \(error.debugDescription)")
            channel.invokeMethod("onError", arguments: error?.debugDescription)
        }
    
}
