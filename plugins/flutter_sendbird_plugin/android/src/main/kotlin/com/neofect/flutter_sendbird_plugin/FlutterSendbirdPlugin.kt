package com.neofect.flutter_sendbird_plugin

import android.content.Context
import androidx.annotation.NonNull
import com.sendbird.android.*
import io.flutter.embedding.engine.FlutterEngine

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterSendbirdPlugin */
class FlutterSendbirdPlugin: FlutterPlugin, MethodCallHandler {

  internal enum class MessagingState {
    Connected, ConnectError,
    Joined, JoinError,
    MessageSent, MessageSendError,
    MessageReceived,
    Disconnected, DisconnectError,
    PreviousMessagesFetched, PreviousMessagesError,
    NextMessagesFetched, NextMessagesError,
    MessageResent, MessageResendError,
    PushTokenRegistered, PushTokenRegisterError,
    PushTokenUnregistered, PushTokenUnregisterError,
    Reconnect, Reconnected,ReconnectError,
    ChannelRefreshed,ChannelRefreshError
  }

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context;

  private lateinit var eventChannel: EventChannel
  private var eventSink:EventChannel.EventSink? = null
  private var unsentMessages  = HashMap<String, UserMessage>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_sendbird_plugin")
//    channel.setMethodCallHandler(this)
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
    channel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventSink = null
        log(TAG, "[onCancel]" + arguments.toString())
      }
    })

    context = flutterPluginBinding.applicationContext
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    log(TAG,"callMethod=${call.method}")

    when(call.method){
      "init" -> {
        val appId = call.argument<String>("app_id")
        if(appId!=null) {
          init(appId,context)
        }
        result.success(null)
      }
      "connect" -> {
        val userId = call.argument<String>("user_id")
        val accessToken = call.argument<String>("access_token")
        if(userId!=null && accessToken!=null){
          connect(userId, accessToken)
        }
        result.success(null)
      }
      "disconnect" -> {
        disconnect()
      }
      "updateUserInfo" -> {
        val nickname = call.argument<String>("nick_name")
        if(nickname!=null){
          updateUserInfo(nickname)
        }
        result.success(null)
      }
      "registerPushToken" -> {
        val pushToken = call.argument<String>("push_token")
        if(pushToken!=null){
          registerPushToken(pushToken)
        }
        result.success(null)
      }
      "unregisterPushToken" -> {
        val pushToken = call.argument<String>("push_token")
        if(pushToken!=null){
          unregisterPushToken(pushToken)
        }
        result.success(null)
      }
      "join" -> {
        val channelName = call.argument<String>("channel_name")
        val userIds = call.argument<List<String>>("user_ids")

        if(channelName !=null && userIds !=null){
          join(channelName,userIds)
        }
        result.success(null)
      }
      "fetchPreviousMessages" -> {
        val timestamp = call.argument<Long>("timestamp")
        val limit = call.argument<Int>("limit")
        val reserve = call.argument<Boolean>("reserve")
        if(timestamp!=null && limit!=null && reserve!=null) {
          getPreviousMessages(timestamp,reserve,limit)
        }
        result.success(null)
      }
      "fetchNextMessages" -> {
        val timestamp = call.argument<Long>("timestamp")
        val limit = call.argument<Int>("limit")
        val reserve = call.argument<Boolean>("reserve")
        if(timestamp!=null && limit!=null && reserve!=null) {
          getNextMessages(timestamp,reserve,limit)
        }
        result.success(null)
      }
      "sendMessage" -> {
        val message = call.argument<String>("message")
        if(message!=null){
          val requestId = sendMessage(message)
          result.success(requestId)
        }else {
          result.success(null)
        }
      }
      "resendMessage" -> {
        val requestId = call.argument<String>("request_id")
        if(requestId!=null){
          resendMessage(requestId)
        }
      }
      "markAsRead"-> {
        markAsRead()
        result.success(null)
      }
      "startTyping" -> {
        startTyping()
        result.success(null)
      }
      "endTyping" -> {
        endTyping()
        result.success(null)
      }
      "reconnect" -> {
        reconnect()
        result.success(null)
      }
      "refreshChannel" -> {
        refreshChannel()
        result.success(null)
      }
      "getConnectionState" -> {
        var connectionState = getConnectionState()
        result.success(connectionState)
      }
      "addConnectionHandler"-> {
        val handlerId = call.argument<String>("handler_id")
        if(handlerId!=null)
          addConnectionHandler(handlerId)
        result.success(null)
      }
      "removeConnectionHandler" -> {
        val handlerId = call.argument<String>("handler_id")
        if(handlerId!=null)
          removeConnectionHandler(handlerId)
        result.success(null)
      }
      "addChannelHandler" -> {
        val handlerId = call.argument<String>("handler_id")
        if(handlerId!=null)
          addChannelHandler(handlerId)
        result.success(null)
      }
      "removeChannelHandler" -> {
        val handlerId = call.argument<String>("handler_id")
        if(handlerId!=null)
          removeChannelHandler(handlerId)
        result.success(null)
      }
      "getUnreadMessageCount" -> {
        val unreadMessageCount = getUnreadMessageCount()
        log(TAG,"getUnreadMessageCount=$unreadMessageCount")
        result.success(unreadMessageCount)
      }
      "clearUnsentMessages" -> {
        clearUnsentMessages()
        result.success(null)
      }
    }
  }




//  init {
//    eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
//    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
//      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
//        eventSink = events
//      }
//
//      override fun onCancel(arguments: Any?) {
//        eventSink = null
//        log(TAG, "[onCancel]" + arguments.toString())
//      }
//    })
//  }

  companion object {
    const val TAG = "SendBirdMessagingPlugin"
    private const val METHOD_CHANNEL_NAME = "sendbird_messaging/method_channel"
    private const val EVENT_CHANNEL_NAME = "sendbird_messaging/event_channel"
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      log(TAG, "[registerWith]")
      val channel = MethodChannel(registrar.messenger(), METHOD_CHANNEL_NAME)
      var sendbirdPlugin  = FlutterSendbirdPlugin()
      channel.setMethodCallHandler(sendbirdPlugin)

      sendbirdPlugin.eventChannel = EventChannel(registrar.messenger(), EVENT_CHANNEL_NAME)
      sendbirdPlugin.eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
          sendbirdPlugin.eventSink = events
        }

        override fun onCancel(arguments: Any?) {
          sendbirdPlugin.eventSink = null
          log(TAG, "[onCancel]" + arguments.toString())
        }
      })
      sendbirdPlugin.context = registrar.activeContext()
    }
  }

  private fun init(appId: String, context: Context){
    SendBird.init(appId,context)
  }

  private fun connect(userId: String, accessToken: String){
    SendBird.connect(userId, accessToken) { user, e ->
      if (e != null) {
        log(TAG,"[connect]error=$e")
        sendErrorToFlutter(MessagingState.ConnectError, e)
      }
      else {
        log(TAG,"[connect]success, userId=${user.userId}, nickname=${user.nickname}")
        sendMessageToFlutter(MessagingState.Connected)
      }
    }
  }

  private fun disconnect() {
    SendBird.disconnect {
      sendMessageToFlutter(MessagingState.Disconnected)
    }
  }

  private fun updateUserInfo(nickname: String){
    log(TAG,"[updateUserInfo]nickname=$nickname");
    SendBird.updateCurrentUserInfo(nickname,null) { e ->
      if (e !=null){
        log(TAG,"[updateUserInfo]error=$e")
      }
      else {
        log(TAG,"[updateUserInfo]success")
      }
    }
  }

  private var groupChannel: GroupChannel? = null

  private fun registerPushToken(fcmToken: String){
    SendBird.registerPushTokenForCurrentUser(fcmToken, SendBird.RegisterPushTokenWithStatusHandler { status , e ->
      if (e !=null){
        log(TAG,"[registerPushToken]error=$e")
        sendErrorToFlutter(MessagingState.PushTokenRegisterError,e)
      }
      else {
        if(status == SendBird.PushTokenRegistrationStatus.PENDING){
          log(TAG,"[registerPushToken]pending")
          sendErrorToFlutter(MessagingState.PushTokenRegisterError, SendBirdException("PushToken registration is pending"))
        }else {
          log(TAG, "[registerPushToken]success, fcmToken=$fcmToken")
          sendMessageToFlutter(MessagingState.PushTokenRegistered)
        }
      }
    })

  }

  private fun unregisterPushToken(pushToken: String){
    SendBird.unregisterPushTokenForCurrentUser(pushToken, SendBird.UnregisterPushTokenHandler { e ->
      if (e !=null) {
        log(TAG, "[unregisterPushToken]error=$e")
        sendErrorToFlutter(MessagingState.PushTokenUnregisterError,e)
      }
      else {
        log(TAG, "[unregisterPushToken]success, pushToken=$pushToken")
        sendMessageToFlutter(MessagingState.PushTokenUnregistered)
      }
    })
  }

  private fun join(channelName: String, userIds: List<String>){
    val params = GroupChannelParams()
            .setPublic(false)
            .setDistinct(true)
            .addUserIds(userIds)
            .setName(channelName)
            .setCustomType("dev")

    GroupChannel.createChannel(params) { groupChannel, e ->
      if (e != null) {
        log(TAG,"onJoinError=$e")
        sendErrorToFlutter(MessagingState.JoinError,e)
      } else {
        this.groupChannel = groupChannel
        log(TAG,"groupChannel url=" + groupChannel.url + " name=" + groupChannel.name)
        sendMessageToFlutter(MessagingState.Joined)
      }
    }
  }

  private fun getPreviousMessages(timestamp:Long, reserve: Boolean, limit:Int){
    groupChannel?.getPreviousMessagesByTimestamp(timestamp,false,limit, reserve, BaseChannel.MessageTypeFilter.USER, null) { messageList, e ->
      if(e!=null){
        log(TAG,"[fetchMessage]error=$e")
        sendErrorToFlutter(MessagingState.PreviousMessagesError,e)
      }else {
        var list = ArrayList<Map<String,Any>>()
        for (baseMessage in messageList) {
          if (baseMessage is UserMessage) {
            list.add(mapOf(
                    "sender_nickname" to baseMessage.sender.nickname,
                    "sender_id" to baseMessage.sender.userId,
                    "request_id" to baseMessage.requestId,
                    "message" to baseMessage.message,
                    "created_at" to baseMessage.createdAt))
          }
        }
        sendMessageToFlutter(MessagingState.PreviousMessagesFetched, mapOf("messages" to list))
      }
    }
  }

  private fun getNextMessages(timestamp:Long, reserve: Boolean, limit:Int){
    groupChannel?.getNextMessagesByTimestamp(timestamp,false,limit, reserve, BaseChannel.MessageTypeFilter.USER, null) { messageList, e ->
      if(e!=null){
        log(TAG,"[fetchMessage]error=$e")
        sendErrorToFlutter(MessagingState.NextMessagesError,e)
      }else {
        var list = ArrayList<Map<String,Any>>()
        for (baseMessage in messageList) {
          if (baseMessage is UserMessage) {
            list.add(mapOf(
                    "sender_nickname" to baseMessage.sender.nickname,
                    "sender_id" to baseMessage.sender.userId,
                    "request_id" to baseMessage.requestId,
                    "message" to baseMessage.message,
                    "created_at" to baseMessage.createdAt))
          }
        }
        sendMessageToFlutter(MessagingState.NextMessagesFetched, mapOf("messages" to list))
      }
    }
  }

  private fun sendMessage(message: String): String? {
    var requestId:String? = null
    requestId = groupChannel?.sendUserMessage(message) { userMessage, e ->
      if (e != null) {
        log(TAG,"[sendMessage]error=$e")
        sendErrorToFlutter(MessagingState.MessageSendError,e, mapOf("request_id" to requestId!!))
        unsentMessages[requestId!!] = userMessage
      }
      else {
        log(TAG, "[sendMessage]success, message=$message")
        sendMessageToFlutter(MessagingState.MessageSent, mapOf("request_id" to requestId!!))
      }
    }?.requestId
    return requestId
  }

  private fun resendMessage(requestId: String) {
    val failedUserMessage = unsentMessages[requestId]
    groupChannel?.resendUserMessage(failedUserMessage) { userMessage, e ->
      if (e !=null){
        log(TAG,"[resendMessage]=$e")
        sendErrorToFlutter(MessagingState.MessageResendError,e, mapOf(
                "request_id" to requestId
        ))
      }
      else {
        sendMessageToFlutter(MessagingState.MessageResent, mapOf(
                "request_id" to requestId
        ))
      }
    }
  }

  private fun clearUnsentMessages(){
    unsentMessages.clear();
  }

  private fun markAsRead() {
    groupChannel?.markAsRead()
  }

  private fun startTyping(){
    groupChannel?.startTyping()
  }

  private fun endTyping(){
    groupChannel?.endTyping()
  }

  private fun reconnect(){
    if(!SendBird.reconnect()){
      sendErrorToFlutter(MessagingState.ReconnectError,SendBirdException("CurrentUser is null || SessionKey is null"))
    }
  }

  private fun refreshChannel(){
    groupChannel?.refresh { e ->
      if (e != null) {
        log(TAG,"[refreshChannel]error=$e")
        sendErrorToFlutter(MessagingState.ChannelRefreshError, e)
      } else {
        sendMessageToFlutter(MessagingState.ChannelRefreshed)
      }
    }
  }

  private fun getConnectionState(): String{
    return SendBird.getConnectionState().toString()
  }

  private fun addConnectionHandler(handlerId: String){
    SendBird.addConnectionHandler(handlerId, object:SendBird.ConnectionHandler{
      override fun onReconnectStarted() {
        sendMessageToFlutter(MessagingState.Reconnect)
      }

      override fun onReconnectSucceeded() {
        sendMessageToFlutter(MessagingState.Reconnected)
      }

      override fun onReconnectFailed() {
        sendErrorToFlutter(MessagingState.ReconnectError, SendBirdException("Failed To Reconnect"))
      }
    })
  }

  private fun removeConnectionHandler(handlerId: String){
    SendBird.removeConnectionHandler(handlerId)
  }

  private fun addChannelHandler(handlerId: String){
    SendBird.addChannelHandler(handlerId, object:SendBird.ChannelHandler(){
      override fun onMessageReceived(baseChannel: BaseChannel?, baseMessage: BaseMessage?) {
        if (baseMessage != null) {
          when (baseMessage) {
            is UserMessage -> {
              sendMessageToFlutter(MessagingState.MessageReceived,mapOf(
                      "sender_nickname" to baseMessage.sender.nickname,
                      "sender_id" to baseMessage.sender.userId,
                      "request_id" to baseMessage.requestId,
                      "message" to baseMessage.message,
                      "created_at" to baseMessage.createdAt))
            }
            is AdminMessage -> {
              log(TAG,"AdminMessage not supported")
            }
            is FileMessage -> {
              log(TAG,"FileMessage not supported")
            }
          }
        } else {
          log(TAG,"baseMessage is null")
        }
      }

    })
  }

  private fun removeChannelHandler(handlerId: String){
    SendBird.removeChannelHandler(handlerId)
  }

  private fun getUnreadMessageCount(): Int{
    return groupChannel?.unreadMessageCount ?: -1
  }

  private fun sendErrorToFlutter(state: MessagingState, e:SendBirdException, params:Map<String,Any>? = null){
    _sendMessageToFlutter(state,e,params)
  }

  private fun sendMessageToFlutter(state: MessagingState, params:Map<String,Any>? = null){
    _sendMessageToFlutter(state,null,params)
  }

  private fun _sendMessageToFlutter(state: MessagingState, e:SendBirdException? = null, params:Map<String,Any>? = null){
    var messageMap:HashMap<String,Any> = if (params!=null) HashMap(params) else HashMap()
    messageMap["state"] = state.toString()
    LogUtils.log(TAG, "state=$state, exception code=${e?.code}, message=${e?.message}")
    if(e!=null)
      messageMap["error"] = e.message ?: "unknown error"
    eventSink?.success(messageMap)
  }

}
