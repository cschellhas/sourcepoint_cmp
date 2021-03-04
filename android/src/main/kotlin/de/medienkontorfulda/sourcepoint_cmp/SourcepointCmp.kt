package de.medienkontorfulda.sourcepoint_cmp

import android.app.Activity
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.sourcepoint.gdpr_cmplibrary.ActionTypes
import com.sourcepoint.gdpr_cmplibrary.GDPRConsentLib
import com.sourcepoint.gdpr_cmplibrary.NativeMessage
import com.sourcepoint.gdpr_cmplibrary.NativeMessageAttrs
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


class SourcepointCmp(registrar: PluginRegistry.Registrar, private val channel: MethodChannel, private val activity: Activity) :
        MethodChannel.MethodCallHandler {

    private val TAG = "**MainActivity"
    private var mainViewGroup: ViewGroup? = null
    private var context = registrar.context();


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> load(call, result)
            "showPM" -> showPM(call, result)
            else -> result.notImplemented()
        }
    }

    private fun buildGDPRConsentLib(accountId: Int, propertyId: Int, propertyName: String, pmId: String): GDPRConsentLib? {
        return GDPRConsentLib.newBuilder(accountId, propertyName, propertyId, pmId, this.context)
                .setOnConsentUIReady { view ->
                    showView(view)
                    if (BuildConfig.DEBUG) {
                        Log.i(TAG, "onConsentUIReady")
                    }
                    channel.invokeMethod("onConsentUIReady", null)
                }
                .setOnConsentUIFinished { view ->
                    removeView(view)
                    if (BuildConfig.DEBUG) {
                        Log.i(TAG, "onConsentUIFinished")
                    }
                    channel.invokeMethod("onConsentUIFinished", null)
                }
                .setOnAction { actionTypes: ActionTypes ->
                    if (BuildConfig.DEBUG) {
                        Log.i(TAG, actionTypes.code.toString())
                    }
                    channel.invokeMethod("onAction", hashMapOf<String, Int>(
                            "actionType" to actionTypes.code
                    ))
                }
                .setOnConsentReady { consent ->
                    if (BuildConfig.DEBUG) {
                        Log.i(TAG, "onConsentReady")
                        Log.i(TAG, "consentString: " + consent.consentString)
                        Log.i(TAG, consent.TCData.toString())
                        for (vendorId in consent.acceptedVendors) {
                            Log.i(TAG, "The vendor $vendorId was accepted.")
                        }
                        for (purposeId in consent.acceptedCategories) {
                            Log.i(TAG, "The category $purposeId was accepted.")
                        }
                        for (purposeId in consent.legIntCategories) {
                            Log.i(TAG, "The legIntCategory $purposeId was accepted.")
                        }
                        for (specialFeatureId in consent.specialFeatures) {
                            Log.i(TAG, "The specialFeature $specialFeatureId was accepted.")
                        }
                    }
                    val map: HashMap<String, Any> = hashMapOf<String, Any>(
                            "consentString" to consent.consentString,
                            "acceptedVendors" to consent.acceptedVendors,
                            "acceptedCategories" to consent.acceptedCategories,
                            "legIntCategories" to consent.legIntCategories,
                            "specialFeatures" to consent.specialFeatures
                    )
                    // consent.toJsonObject().toString()
                    channel.invokeMethod("onConsentReady", map)
                }
                .setOnError { error ->
                    Log.e(TAG, "Something went wrong: ", error)
                    Log.i(TAG, "ConsentLibErrorMessage: " + error.consentLibErrorMessage)
                    channel.invokeMethod("onError", error.consentLibErrorMessage)
                }
                .build()
    }



    private fun load(call: MethodCall, result: MethodChannel.Result) {
        val arguments: Map<String, Any> = call.arguments()
        val accountId = arguments["accountId"] as? Int ?: 22
        val propertyId = arguments["propertyId"] as? Int ?: 7639
        val propertyName = arguments["propertyName"] as? String ?: "tcfv2.mobile.webview"
        val pmId = arguments["pmId"] as? String ?: "122058"

        buildGDPRConsentLib(accountId,propertyId,propertyName,pmId)?.run();

    }

    private fun showView(view: View) {
        if (view.parent == null) {
            val marginParams = ViewGroup.MarginLayoutParams(0,0)
            marginParams.setMargins(0, 50, 0, 0)
            marginParams.height = ViewGroup.LayoutParams.MATCH_PARENT
            marginParams.width = ViewGroup.LayoutParams.MATCH_PARENT
            view.layoutParams = marginParams

            view.bringToFront()
            view.requestLayout()
            mainViewGroup = activity.findViewById<ViewGroup>(android.R.id.content)
            mainViewGroup!!.addView(view)
        }
    }

    private fun showPM(call: MethodCall, result: MethodChannel.Result) {
        val arguments: Map<String, Any> = call.arguments()

        val accountId = arguments["accountId"] as? Int ?: 22
        val propertyId = arguments["propertyId"] as? Int ?: 7639
        val propertyName = arguments["propertyName"] as? String ?: "tcfv2.mobile.webview"
        val pmId = arguments["pmId"] as? String ?: "122058"

        buildGDPRConsentLib(accountId,propertyId,propertyName,pmId)?.showPm()
    }


    private fun removeView(view: View) {
        if (view.parent != null) mainViewGroup!!.removeView(view)
    }

}