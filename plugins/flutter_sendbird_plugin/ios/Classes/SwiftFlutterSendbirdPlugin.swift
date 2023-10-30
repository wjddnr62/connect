import Flutter
import UIKit
import SendBirdSDK

enum MessagingState : String{
    case Connected, ConnectError,
         Joined, JoinError,
         MessageSent, MessageSendError,
         MessageReceived,
         Disconnected, DisconnectError,
         PreviousMessagesFetched, PreviousMessagesError,
         NextMessagesFetched, NextMessagesError,
         MessageResent, MessageResendError,
         appResume, appPause,
         PushTokenRegistered, PushTokenRegisterError,
         PushTokenUnregistered, PushTokenUnregisterError,
         Reconnect, Reconnected,ReconnectError,
         ChannelRefreshed,ChannelRefreshError
}

public class SwiftFlutterSendbirdPlugin: NSObject, FlutterPlugin {
    
    let messenger:FlutterBinaryMessenger
    var eventChannel:FlutterEventChannel
    var eventSink:FlutterEventSink?
    
    var groupChannel:SBDGroupChannel?
    var unsentMessages:Dictionary<String,SBDUserMessage> = Dictionary<String,SBDUserMessage>()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sendbird_messaging/method_channel", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSendbirdPlugin(registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(_ messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        self.eventChannel = FlutterEventChannel(name: "sendbird_messaging/event_channel", binaryMessenger: messenger)
        super.init()
        self.eventChannel.setStreamHandler(self)
    }
    
    public static func registerApnsDeviceToken(_ deviceToken:Data){
        UserDefaults.standard.set(deviceToken, forKey: "apns_device_token")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String,Any> else { return }
        debugPrint("[onMethodCall]call.method=\(call.method)")
        switch call.method {
        case "init":
            if let appId = args["app_id"] as? String {
                self.initialize(appId)
            }
            result(nil)
            break
        case "connect":
            if let userId = args["user_id"] as? String,
               let accesToken = args["access_token"] as? String {
                connect(userId, accesToken)
            }
            result(nil)
            break
        case "disconnect":
            disconnect()
            result(nil)
            break
        case "updateUserInfo":
            if let nickname = args["nick_name"] as? String {
                updateUserInfo(nickname)
            }
            result(nil)
            break
        case "registerPushToken":
            if let apnsToken = UserDefaults.standard.object(forKey: "apns_device_token") as? Data {
                registerPushToken(apnsToken)
            }else {
                let error = "apns device token is empty";
                debugPrint("[registerPushToken]error=\(error)")
                self.sendErrorToFlutter(MessagingState.PushTokenRegisterError, error)
            }
            result(nil)
            break
        case "unregisterPushToken":
            if let apnsToken = UserDefaults.standard.object(forKey: "apns_device_token") as? Data {
                unregisterPushToken(apnsToken)
            }else {
                let error = "apns device token is empty";
                debugPrint("[unregisterPushToken]error=\(error)")
                self.sendErrorToFlutter(MessagingState.PushTokenRegisterError, error)
            }
            result(nil)
            break
        case "join":
            if let channelName = args["channel_name"] as? String,
               let userIds = args["user_ids"] as? Array<String> {
                join(channelName, userIds)
            }
            result(nil)
            break
        case "fetchPreviousMessages":
            if let timestamp = args["timestamp"] as? Int64,
               let limit = args["limit"] as? Int,
               let reserve = args["reserve"] as? Bool {
                getPreviousMessages(timestamp, reserve, limit)
            }
            result(nil)
            break
        case "fetchNextMessages":
            if let timestamp = args["timestamp"] as? Int64,
               let limit = args["limit"] as? Int,
               let reserve = args["reserve"] as? Bool {
                getNextMessages(timestamp, reserve, limit)
            }
            result(nil)
            break;
        case "sendMessage":
            if let message = args["message"] as? String {
                if let requetsId = sendMessage(message){
                    result(requetsId)
                    return
                }
            }
            result(nil)
            break
        case "resendMessage":
            if let requestId = args["request_id"] as? String {
                resendMessage(requestId)
            }
            result(nil)
            break
        case "markAsRead":
            markAsRead()
            result(nil)
            break;
        case "startTyping":
            startTyping()
            result(nil)
            break
        case "endTyping":
            endTyping()
            result(nil)
            break
        case "reconnect":
            reconnect()
            result(nil)
            break
        case "refreshChannel":
            refreshChannel()
            result(nil)
            break
        case "getConnectionState":
            result(getConnectionState())
            break
        case "addConnectionHandler":
            if let handlerId = args["handler_id"] as? String {
                addConnectionHandler(handlerId: handlerId)
            }
            result(nil)
            break
        case "removeConnectionHandler":
            if let handlerId = args["handler_id"] as? String {
                removeConnectionHandler(handlerId: handlerId)
            }
            result(nil)
            break
        case "addChannelHandler":
            if let handlerId = args["handler_id"] as? String {
                addChannelHandler(handlerId: handlerId)
            }
            result(nil)
            break
        case "removeChannelHandler":
            if let handlerId = args["handler_id"] as? String {
                removeChannelHandler(handlerId: handlerId)
            }
            result(nil)
            break
        case "getUnreadMessageCount":
            result(getUnreadMessageCount())
            break
        case "clearUnsentMessages":
            clearUnsentMessages()
            result(nil)
            break
        default:
            break;
        }
    }
    
    private func sendMessageToFlutter(_ state: MessagingState, _ params:Dictionary<String,Any>? = nil){
        _sendMessageToFlutter(state,nil,params)
    }
    
    private func sendErrorToFlutter(_ state: MessagingState, _ error: Any? = nil, _ params:Dictionary<String, Any>? = nil){
        _sendMessageToFlutter(state,error,params);
    }
    
    private func _sendMessageToFlutter(_ state: MessagingState, _ error: Any? = nil, _ params:Dictionary<String, Any>? = nil){
        debugPrint("[_sendMessageToFlutter]state=\(state), error=\(error ?? "")")
        if var dic = ((params != nil) ? params : Dictionary<String, Any>()){
            dic["state"] = state.rawValue
            if error != nil {
                dic["error"] = error is NSError ? (error as! NSError).description : error
            }
            
            eventSink?(dic)
        }
    }
    
    private func initialize(_ appId: String){
        SBDMain.initWithApplicationId(appId)
    }
    
    private func connect(_ userId: String, _ accessToken: String){
        SBDMain.connect(withUserId: userId, accessToken: accessToken){ (user,error) in
            if let err = error {
                debugPrint("[connect]error=\(err)")
                self.sendErrorToFlutter(MessagingState.ConnectError, err)
            }
            else {
                debugPrint("[connect]success, userId=\(user?.userId ?? "")}")
                self.sendMessageToFlutter(MessagingState.Connected)
            }
        }
    }
    
    private func disconnect(){
        SBDMain.disconnect{
            self.sendMessageToFlutter(MessagingState.Disconnected)
        }
    }
    
    private func updateUserInfo(_ nickname: String){
        SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: nil) { (error) in
            if let err = error {
                debugPrint("[updateUserInfo]error=\(err)")
            }
            else {
                debugPrint("[updateUserInfo]success : nickname")
            }
        }
    }
    
    private func registerPushToken(_ apnsToken: Data){
        SBDMain.registerDevicePushToken(apnsToken, unique: false){ (status, error) in
            if let err = error {
                debugPrint("[registerPushToken]error=\(err)")
                self.sendErrorToFlutter(MessagingState.PushTokenRegisterError, err)
            }
            else {
                if status == SBDPushTokenRegistrationStatus.pending {
                    debugPrint("[registerPushToken]pending")
                    self.sendErrorToFlutter(MessagingState.PushTokenRegisterError,"PushToken registration is pending")
                }
                else {
                    debugPrint("[registerPushToken]success")
                    self.sendMessageToFlutter(MessagingState.PushTokenRegistered)
                }
            }
        }
    }
    
    private func unregisterPushToken(_ apnsToken: Data){
        SBDMain.unregisterPushToken(apnsToken) { (response, error) in
            if let err = error {
                debugPrint("[unregisterPushToken]error=\(err)")
                self.sendErrorToFlutter(MessagingState.PushTokenUnregisterError, err)
            }
            else {
                debugPrint("[unregisterPushToken]success")
                self.sendMessageToFlutter(MessagingState.PushTokenUnregistered)
            }
        }
    }
    
    private func join(_ channelName: String, _ userIds: Array<String>){
        let params = SBDGroupChannelParams.init()
        params.isPublic = false
        params.isDistinct = true
        params.addUserIds(userIds)
        params.name = channelName
        params.customType = "dev"
        
        SBDGroupChannel.createChannel(with: params) { (group, error) in
            if let err = error {
                debugPrint("[join]error=\(err)")
                self.sendErrorToFlutter(MessagingState.JoinError,err)
            }
            else {
                debugPrint("[join]success")
                self.sendMessageToFlutter(MessagingState.Joined)
                
                self.groupChannel = group
            }
        }
    }
    
    private func getPreviousMessages(_ timestamp: Int64, _ reserve: Bool, _ limit: Int){
        groupChannel?.getPreviousMessages(byTimestamp: timestamp, limit: limit, reverse: reserve, messageType: SBDMessageTypeFilter.user, customType: nil, senderUserIds: nil, completionHandler: { (messages, error) in
            if let err = error {
                debugPrint("[getPreviousMessages]error=\(err)")
                self.sendErrorToFlutter(MessagingState.PreviousMessagesError, err)
            }else {
                var messageList = Array<Dictionary<String,Any>>()
                for message in messages! {
                    if let userMessage = message as? SBDUserMessage {
                        messageList.append(["sender_nickname" : userMessage.sender!.nickname ?? "",
                                            "sender_id" : userMessage.sender!.userId,
                                            "request_id" : userMessage.requestId!,
                                            "message" : userMessage.message ?? "",
                                            "created_at" : userMessage.createdAt])
                    }
                }
                self.sendMessageToFlutter(MessagingState.PreviousMessagesFetched,["messages" : messageList])
            }
        })
    }
    
    private func getNextMessages(_ timestamp: Int64, _ reserve: Bool, _ limit: Int){
        groupChannel?.getNextMessages(byTimestamp: timestamp, limit: limit, reverse: reserve, messageType: SBDMessageTypeFilter.user, customType: nil, senderUserIds: nil, completionHandler: { (messages, error) in
            if let err = error {
                debugPrint("[getNextMessages]error=\(err)")
                self.sendErrorToFlutter(MessagingState.NextMessagesError, err)
            }else {
                var messageList = Array<Dictionary<String,Any>>()
                for message in messages! {
                    if let userMessage = message as? SBDUserMessage {
                        messageList.append(["sender_nickname" : userMessage.sender!.nickname ?? "",
                                            "sender_id" : userMessage.sender!.userId,
                                            "request_id" : userMessage.requestId!,
                                            "message" : userMessage.message ?? "",
                                            "created_at" : userMessage.createdAt])
                    }
                }
                self.sendMessageToFlutter(MessagingState.NextMessagesFetched,["messages" : messageList])
            }
        })
    }
    
    private func sendMessage(_ message: String) -> String? {
        var requestId:String! = nil
        if let groupChannel = self.groupChannel {
            let userMessage = groupChannel.sendUserMessage(message, completionHandler: { (userMessage, error) in
                if let err = error {
                    debugPrint("[sendMessage]error=\(err)")
                    self.sendErrorToFlutter(MessagingState.MessageSendError, err)
                    self.unsentMessages[requestId] = userMessage
                }else {
                    debugPrint("[sendMessage]success")
                    self.sendMessageToFlutter(MessagingState.MessageSent,["request_id" : requestId ?? -1])
                    //                    self.failedUserMessageDic.removeValue(forKey: requestId)
                }
            })
            requestId = userMessage.requestId
        }
        return requestId
    }
    
    private func resendMessage(_ requestId: String){
        if let groupChannel = self.groupChannel, let failedUserMessage = unsentMessages[requestId] {
            groupChannel.resendUserMessage(with: failedUserMessage) { (userMessage, error) in
                if let err = error {
                    debugPrint("[resendMessage]error=\(err)")
                    self.sendErrorToFlutter(MessagingState.MessageResendError,err)
                }else {
                    self.sendMessageToFlutter(MessagingState.MessageResent)
                    self.unsentMessages.removeValue(forKey: requestId)
                }
            }
        }
    }
    
    private func markAsRead() {
        groupChannel?.markAsRead()
    }
    
    private func startTyping(){
        groupChannel?.startTyping()
    }
    
    private func endTyping(){
        groupChannel?.endTyping()
    }
    
    private func reconnect(){
        if(!SBDMain.reconnect()){
            debugPrint("[reconnect]error=CurrentUser is null || SessionKey is null")
            sendErrorToFlutter(MessagingState.ReconnectError, "CurrentUser is null || SessionKey is null")
        }
    }
    
    private func refreshChannel(){
        groupChannel?.refresh(completionHandler: { (error) in
            if let err = error {
                debugPrint("[refreshChannel]error=\(err)")
                self.sendErrorToFlutter(MessagingState.ChannelRefreshError, err)
            }
            else {
                debugPrint("[refreshChannel]success")
                self.sendMessageToFlutter(MessagingState.ChannelRefreshed)
            }
        })
    }
    
    private func getConnectionState()-> String{
        let state = SBDMain.getConnectState()
        switch state {
        case SBDWebSocketConnectionState.connecting:
            return "CONNECTING";
        case SBDWebSocketConnectionState.open:
            return "OPEN"
        case SBDWebSocketConnectionState.closed:
            return "CLOSED"
        default:
            return "UNKNOWN"
        }
    }
    
    private func addConnectionHandler(handlerId: String){
        SBDMain.add(self as SBDConnectionDelegate, identifier: handlerId)
    }
    
    private func removeConnectionHandler(handlerId: String){
        SBDMain.removeConnectionDelegate(forIdentifier: handlerId)
    }
    
    private func addChannelHandler(handlerId: String){
        SBDMain.add(self as SBDChannelDelegate, identifier: handlerId)
    }
    
    private func removeChannelHandler(handlerId: String){
        SBDMain.removeChannelDelegate(forIdentifier: handlerId)
    }
    
    private func getUnreadMessageCount() -> Int{
        if let channel = groupChannel {
            return Int(channel.unreadMessageCount)
        }
        else {
            return -1
        }
    }
    
    private func clearUnsentMessages(){
        unsentMessages.removeAll()
    }
}

// MARK: - FlutterStreamHandler callbacks
extension SwiftFlutterSendbirdPlugin: FlutterStreamHandler{
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - SBDConnectionDelegate callbacks
extension SwiftFlutterSendbirdPlugin: SBDConnectionDelegate {
    
    public func didStartReconnection() {
        self.sendMessageToFlutter(MessagingState.Reconnect)
    }
    
    public func didSucceedReconnection() {
        self.sendMessageToFlutter(MessagingState.Reconnected)
    }
    
    public func didFailReconnection() {
        self.sendErrorToFlutter(MessagingState.ReconnectError,"Failed to reconnect")
    }
    
    public func didCancelReconnection() {
        self.sendErrorToFlutter(MessagingState.ReconnectError,"Cancel to reconnect")
    }
}

// MARK: - SBDChannelDelegate callbacks
extension SwiftFlutterSendbirdPlugin: SBDChannelDelegate {
    
    public func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender == self.groupChannel {
            if let userMessage = message as? SBDUserMessage {
                sendMessageToFlutter(MessagingState.MessageReceived,
                                     ["sender_nickname" : userMessage.sender!.nickname ?? "",
                                      "sender_id" : userMessage.sender!.userId,
                                      "request_id" : userMessage.requestId!,
                                      "message" : userMessage.message ?? "",
                                      "created_at" : userMessage.createdAt])
            }
        }
    }
}
