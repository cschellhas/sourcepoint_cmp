package de.medienkontorfulda.sourcepoint_cmp

import android.app.Activity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

/** SourcepointCmpPlugin */
class SourcepointCmpPlugin {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val activity = registrar.activity()
      if (activity == null) {
        // When a background flutter view tries to register the plugin, the registrar has no activity.
        // We stop the registration process as this plugin is foreground only.
        return;
      }
      val interstitialChannel =
              MethodChannel(registrar.messenger(), "sourcepoint_cmp")
      interstitialChannel.setMethodCallHandler(SourcepointCmp(registrar, interstitialChannel, activity))

    }
  }
}
