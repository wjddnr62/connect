package com.neofect.connect

import android.util.Log
import com.appsflyer.AppsFlyerConversionListener
import com.appsflyer.AppsFlyerLib
import com.appsflyer.AppsFlyerLibCore.LOG_TAG
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService

class ConnectApplication : FlutterApplication(), PluginRegistrantCallback {

    private val devKey = "M6AHjpZuXusVPS6pj4nZBd";

    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
        val conversionDataListener  = object : AppsFlyerConversionListener {
            override fun onConversionDataSuccess(data: MutableMap<String, Any>?) {
                data?.let { cvData ->
                    cvData.map {
                        Log.i(LOG_TAG, "conversion_attribute:  ${it.key} = ${it.value}")
                    }
                }
            }

            override fun onConversionDataFail(error: String?) {
                Log.e(LOG_TAG, "error onAttributionFailure :  $error")
            }

            override fun onAppOpenAttribution(data: MutableMap<String, String>?) {
                data?.map {
                    Log.d(LOG_TAG, "onAppOpen_attribute: ${it.key} = ${it.value}")
                }
            }

            override fun onAttributionFailure(error: String?) {
                Log.e(LOG_TAG, "error onAttributionFailure :  $error")
            }


        }

        AppsFlyerLib.getInstance().init(devKey, conversionDataListener, this)
        AppsFlyerLib.getInstance().startTracking(this)
        AppsFlyerLib.getInstance().setDebugLog(BuildConfig.DEBUG);

    }

    override fun registerWith(registry: PluginRegistry) {
        CustomPluginRegistrant.registerWith(registry)
    }
}