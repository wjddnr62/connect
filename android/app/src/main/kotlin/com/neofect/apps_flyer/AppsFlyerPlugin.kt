package com.neofect.apps_flyer

import android.content.Context
import android.util.Log
import com.appsflyer.AFInAppEventParameterName
import com.appsflyer.AFInAppEventType
import com.appsflyer.AppsFlyerLib
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class AppsFlyerPlugin internal constructor(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val TAG = "AppsFlyerPlugin"
        private const val METHOD_CHANNEL_NAME = "appsflyer/method_channel"

        @JvmStatic
        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            Log.d(TAG, "[registerWith]")
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
            channel.setMethodCallHandler(AppsFlyerPlugin(context))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "callMethod=${call.method}")
        when (call.method) {
            "saveLog" -> {
                val saveLog = call.argument<String>("saveLog")
                val map: Map<String, String> = mapOf("dummy" to "a")
                AppsFlyerLib.getInstance().trackEvent(context, saveLog, map)
                result.success(null)
            }
        }
    }

}