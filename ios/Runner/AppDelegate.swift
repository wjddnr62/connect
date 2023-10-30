import UIKit
import Flutter
import Fabric
import Crashlytics
import flutter_sendbird_plugin
import AppsFlyerLib

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,AppsFlyerTrackerDelegate {
    
    let appsFlyerDevKey = "M6AHjpZuXusVPS6pj4nZBd";
    let appleAppID = "1473561369";
    
    @objc func sendLaunch(app:Any) {
         AppsFlyerTracker.shared().trackAppLaunch()
     }
     
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        //firebase_messaging setting
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        GeneratedPluginRegistrant.register(with: self)
        
        Fabric.with([Crashlytics.self])
        
        //AppsFlyer
        AppsFlyerTracker.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerTracker.shared().appleAppID = appleAppID
        AppsFlyerTracker.shared().delegate = self
        /* Set isDebug to true to see AppsFlyer debug logs */
        #if DEBUG
            AppsFlyerTracker.shared().isDebug = true
        #else
            AppsFlyerTracker.shared().isDebug = false
        #endif

        
        NotificationCenter.default.addObserver(self,
        selector: #selector(sendLaunch),
        name: UIApplication.didBecomeActiveNotification,
        object: nil)
        
        AppsFlyerPlugin.register(with: registrar(forPlugin: "com.neofect.flutter_apps_flyer.AppsFlyerPlugin") as! FlutterPluginRegistrar)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // AppDelegate.swift
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Register a device token to SendBird server.
        SwiftFlutterSendbirdPlugin.registerApnsDeviceToken(deviceToken)
    }
    
    //AppsFlyer Setting
    
    // Deeplinking
     
     // Open URI-scheme for iOS 9 and above
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         AppsFlyerTracker.shared().handleOpen(url, options: options)
         return true
     }
     
     // Open URI-scheme for iOS 8 and below
    override func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       AppsFlyerTracker.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
       return true
     }
     
     // Open Univerasal Links
     // For Swift version < 4.2 replace function signature with the commented out code
     // func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool { // this line for Swift < 4.2
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
         AppsFlyerTracker.shared().continue(userActivity, restorationHandler: nil)
         return true
     }
     
     //Conflict FCM plugin
     // Report Push Notification attribution data for re-engagements
//    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//         AppsFlyerTracker.shared().handlePushNotification(userInfo)
//     }
     
     // AppsFlyerTrackerDelegate implementation
     
     //Handle Conversion Data (Deferred Deep Link)
     func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
         print("\(data)")
         if let status = data["af_status"] as? String{
             if(status == "Non-organic"){
                 if let sourceID = data["media_source"] , let campaign = data["campaign"]{
                     print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                 }
             } else {
                 print("This is an organic install.")
             }
             if let is_first_launch = data["is_first_launch"] , let launch_code = is_first_launch as? Int {
                 if(launch_code == 1){
                     print("First Launch")
                 } else {
                     print("Not First Launch")
                 }
             }
         }
     }
     func onConversionDataFail(_ error: Error) {
        print("\(error)")
     }
     
     //Handle Direct Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
         //Handle Deep Link Data
         print("onAppOpenAttribution data:")
         for (key, value) in attributionData {
             print(key, ":",value)
         }
     }
     func onAppOpenAttributionFailure(_ error: Error) {
         print("\(error)")
     }
     
//     // support for scene delegate
//     // MARK: UISceneSession Lifecycle
//     @available(iOS 13.0, *)
//    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//         // Called when a new scene session is being created.
//         // Use this method to select a configuration to create the new scene with.
//         return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//     }
//     @available(iOS 13.0, *)
//    override func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//         // Called when the user discards a scene session.
//         // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//         // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//     }
}
