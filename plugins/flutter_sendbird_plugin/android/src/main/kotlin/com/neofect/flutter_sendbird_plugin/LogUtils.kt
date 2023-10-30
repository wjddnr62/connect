package com.neofect.flutter_sendbird_plugin
import android.util.Log

class LogUtils{

    companion object {
        var logged = true

        fun log(tag: String, log: String){
            if(!logged) return
            Log.d(tag, log)
        }
    }
}

inline fun log(tag: String, message: String) = LogUtils.log(tag,message)
