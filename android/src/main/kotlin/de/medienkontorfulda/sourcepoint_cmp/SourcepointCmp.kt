package de.medienkontorfulda.sourcepoint_cmp

import android.app.Activity
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.sourcepoint.cmplibrary.NativeMessageController
import com.sourcepoint.cmplibrary.SpClient
import com.sourcepoint.cmplibrary.SpConsentLib
import com.sourcepoint.cmplibrary.core.nativemessage.MessageStructure
import com.sourcepoint.cmplibrary.creation.config
import com.sourcepoint.cmplibrary.creation.delegate.spConsentLibLazy
import com.sourcepoint.cmplibrary.exception.CampaignType
import com.sourcepoint.cmplibrary.model.ConsentAction
import com.sourcepoint.cmplibrary.model.MessageLanguage
import com.sourcepoint.cmplibrary.model.PMTab
import com.sourcepoint.cmplibrary.model.exposed.SPConsents
import com.sourcepoint.cmplibrary.model.exposed.SpConfig
//import com.sourcepoint.gdpr_cmplibrary.ActionTypes
//import com.sourcepoint.gdpr_cmplibrary.GDPRConsentLib
//import com.sourcepoint.gdpr_cmplibrary.NativeMessage
//import com.sourcepoint.gdpr_cmplibrary.NativeMessageAttrs
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback

class SourcepointCmp(private val channel: MethodChannel) :
    MethodChannel.MethodCallHandler {

    //    private val TAG = "**MainActivity"
    private var TAG: String = SourcepointCmp::class.java.name
    private var mainViewGroup: ViewGroup? = null
    private var currentView: View? = null
    private var spConsentLib: SpConsentLib? = null
    lateinit var activity: Activity
//    private val spConsentLib by spConsentLibLazy {
//        activity
//        spClient = LocalClient()
//    }

    internal inner class LocalClient : SpClient {
        override fun onConsentReady(consent: SPConsents) {

            if (BuildConfig.DEBUG) {
                Log.i(TAG, "onConsentReady")
                Log.i(TAG, "consentString: " + consent.gdpr?.consent.toString())
                Log.i(TAG, consent.gdpr.toString())
            }

            val grants = consent.gdpr?.consent?.grants
            val acceptedVendors: MutableList<String> = mutableListOf()

            grants?.forEach { grant ->
                val granted = grants[grant.key]?.granted
                val purposes = grants[grant.key]?.purposeGrants
                println("vendor: ${grant.key} - granted: $granted - purposes: $purposes")
                acceptedVendors.add(grant.key)
            }

            val map: HashMap<String, Any> = hashMapOf<String, Any>(
                "consentString" to consent.gdpr?.consent?.euconsent as Any,
                "acceptedVendors" to acceptedVendors,
//                "acceptedCategories" to consent.acceptedCategories,
//                "legIntCategories" to consent.legIntCategories,
//                "specialFeatures" to consent.specialFeatures
            )
            // consent.toJsonObject().toString()
            channel.invokeMethod("onConsentReady", map)
        }

        override fun onError(error: Throwable) {
            Log.e(TAG, "Something went wrong: ", error)
            this@SourcepointCmp.activity.runOnUiThread {
                channel.invokeMethod("onError", error.toString())
            }
        }

        override fun onMessageReady(message: JSONObject) {
            TODO("Not yet implemented")
        }

        override fun onNativeMessageReady(message: MessageStructure, messageController: NativeMessageController) {
            TODO("Not yet implemented")
        }

        override fun onNoIntentActivitiesFound(url: String) {
            Log.w(TAG, "onNoIntentActivitiesFound: $url")
        }

        override fun onSpFinished(sPConsents: SPConsents) {
            Log.i(TAG, "onSpFinished")
        }

        override fun onUIFinished(view: View) {
            spConsentLib?.removeView(view)
            currentView = null
//            spConsentLib = null

            if (BuildConfig.DEBUG) {
                Log.i(TAG, "onUIFinished")
            }
            channel.invokeMethod("onConsentUIFinished", null)
        }

        override fun onUIReady(view: View) {
            spConsentLib?.showView(view)
            currentView = view;

            if (BuildConfig.DEBUG) {
                Log.i(TAG, "onConsentUIReady")
            }
            channel.invokeMethod("onConsentUIReady", null)
        }

        override fun onAction(view: View, consentAction: ConsentAction): ConsentAction {
            if (BuildConfig.DEBUG) {
                Log.i(TAG, consentAction.actionType.toString())
            }
            this@SourcepointCmp.activity.runOnUiThread {
                channel.invokeMethod(
                    "onAction", hashMapOf<String, Any?>(
                        "actionType" to consentAction.actionType.code,
                        "customActionId" to consentAction.customActionId
                    )
                )
//                spConsentLib?.removeView(view)
//                currentView = null
            }


            return consentAction
        }


    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> load(call, result)
            "showPM" -> showPM(call, result)
            "hideView" -> hideView(call, result)
            else -> result.notImplemented()
        }
    }


    private fun load(call: MethodCall, result: MethodChannel.Result) {
        val arguments: Map<String, Any>? = call.arguments()
        val accountIdVal: Int = arguments?.get("accountId") as Int
        val propertyIdVal = arguments?.get("propertyId") as Int
        val propertyNameVal: String = arguments?.get("propertyName") as String
        val pmId = arguments?.get("pmId") as String

        Log.i(TAG, "show consent")

        if (this.spConsentLib == null) {


            // wird nur ausgeführt wenn man in der App schon nicht mehr zurück kann, also auf der Home startet
//            val callback: OnBackPressedCallback =
//                object : OnBackPressedCallback(true) {
//                    override fun handleOnBackPressed() {
//                        // Leave empty do disable back press or
//                        // write your code which you want
//                        Log.i(TAG, "!!!! back pressed !!!!!!!");
//                    }
//                }
//
//            (activity as ComponentActivity).onBackPressedDispatcher.addCallback(activity, callback)

            val cmpConfig: SpConfig = config {
                accountId = accountIdVal
                propertyName = propertyNameVal
                messLanguage = MessageLanguage.GERMAN
                +CampaignType.GDPR
            }

            val consentLib by spConsentLibLazy {
                activity = this@SourcepointCmp.activity
                spClient = LocalClient()
                spConfig = cmpConfig
            }

            spConsentLib = consentLib

        }
        spConsentLib?.loadMessage()
    }


    private fun hideView(call: MethodCall, result: MethodChannel.Result) {
        currentView?.let { spConsentLib?.removeView(it) }
    }

    private fun showPM(call: MethodCall, result: MethodChannel.Result) {
        val arguments: Map<String, Any>? = call.arguments()

        Log.i(TAG, "showPM")

        val accountIdVal = arguments?.get("accountId") as Int
        val propertyId = arguments?.get("propertyId") as Int
        val propertyNameVal = arguments?.get("propertyName") as String
        val pmIdVal = arguments?.get("pmId") as String


        if (this.spConsentLib == null) {

            val cmpConfig: SpConfig = config {
                accountId = accountIdVal
                propertyName = propertyNameVal
                messLanguage = MessageLanguage.GERMAN
                +CampaignType.GDPR
            }

            val consentLib by spConsentLibLazy {
                activity = this@SourcepointCmp.activity
                spClient = LocalClient()
                spConfig = cmpConfig
            }
            spConsentLib = consentLib
        }

        spConsentLib?.loadPrivacyManager(pmIdVal, PMTab.PURPOSES, CampaignType.GDPR)
    }

}
