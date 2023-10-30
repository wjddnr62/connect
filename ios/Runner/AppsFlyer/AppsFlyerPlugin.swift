//
//  AppsflyerPlugin.swift
//  Runner
//
//  Created by LeeJoungWook on 2020/09/22.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import AppsFlyerLib

public class AppsFlyerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "appsflyer/method_channel", binaryMessenger: registrar.messenger())
        let instance = AppsFlyerPlugin()
        
        channel.setMethodCallHandler(instance.onMethodCall)
    }
    
    public func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String,Any> else { return }
        debugPrint("[onMethodCallAppsFlyer]call.method=\(call.method)")
        
        switch call.method {
        case "saveLog":
            if let saveLog = args["saveLog"] as? String {
                AppsFlyerTracker.shared().trackEvent(saveLog, withValues: [AFEventParamLevel
                    : 1, AFEventParamScore: 1])
            }
            result(nil)
            break
        default:
            break
        }
    }
}

