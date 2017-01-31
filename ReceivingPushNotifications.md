# Receiving push notifications from Apple's Push Notification and Google's Firebase Cloud Messaging services

In the [previous article](https://blog.grijjy.com/2017/01/18/sending-ios-and-android-remote-push-notifications-from-your-delphi-service-with-the-http2-protocol/) we demonstrated how to roll your own Google Firebase Cloud Messaging and Apple APNS push notifications from Delphi apps in a unified manner.  This article continues the conversation about how to easily receive and consume them in your Delphi mobile app.

# Introduction
If you are authoring a Delphi service for the cloud, you may have the need to send and receive push notifications from your service to your mobile client application.  You could use an existing BAAS provider to accomplish this, but why pay for this when you can roll your own so easily with Delphi?

Delphi provides a base set of classes in the units `FMX.PushNotification.Android` and `FMX.PushNotification.iOS` that do most of the heavy lifting and allow you to easily consume remote push notifications.  In this conversation we will be demonstrating a helper class that unifies the approach for both platforms, uses TMessage callbacks for notifications and device token changes and adds some new missing features.

For more information about us, our support and services visit the [Grijjy homepage](http://www.grijjy.com) or the [Grijjy developers blog](http://blog.grijjy.com).

The example contained here depends upon part of our [Grijjy Foundation library](https://github.com/grijjy/GrijjyFoundation).

# Getting started on iOS
To receive push notifications on iOS you must:

1. Already have created an [Apple Push Services certificate in the Apple Developer website](https://developer.apple.com/account/ios/certificate/) for use in sending remote push notifications.

2. Create an App ID on the Apple Developer website for your project.

3. Enable Push Notifications for your App ID on the Apple Developer website for your project.
 
4. A Provisioning Profile must exist on the Apple website that matches the identifier.

Then in your Delphi Project Options you must set your CFBundleIdentifier for iOS build configurations to the matching name of the ID in Apple Developer website. (ex: com.some.app)  This is the only thing your app will need to identify itself for Apple Push Notifications.  

# Getting started on Android
To receive push notifications on Android you must:

1. Obtain a Firebase Cloud Messaging API Key by setting up cloud messaging on [Google's developer site](https://developers.google.com/cloud-messaging/).  This is also called the Server API Key under Firebase Cloud Messaging.

2. Modify your AndroidManifest.xml to register an Intent and add the following receiver:

```xml
  <receiver
  android:name="com.embarcadero.gcm.notifications.GCMNotification" android:exported="true"
  android:permission="com.google.android.c2dm.permission.SEND" >
  <intent-filter>
    <action android:name="com.google.android.c2dm.intent.RECEIVE" />
    <category android:name="%package%" />
  </intent-filter>
  </receiver>
  <service android:name="com.embarcadero.gcm.notifications.GCMIntentService" />
  <%receivers%>
```
For Android, we only need the Firebase Cloud Messaging API Key for our Delphi app. 

# TgoRemotePushReceiver class
The [TgoRemotePushReceiver class](https://github.com/grijjy/GrijjyFoundation/blob/master/Grijjy.RemotePush.Receiver.pas) unifies the receiving of remote push notifications from both APNS and Firebase Cloud Messaging into a common class model.
```Delphi
  TgoRemotePushReceiver = class(TObject)
  public
    constructor Create(const AGCMAppId: UnicodeString);
    destructor Destroy; override;
  public
    property DeviceToken: String read FDeviceToken;
    property Number: Integer read GetNumber write SetNumber;
  end;
```

When you receive a remote push notification message from Android or iOS, the following TMessage is fired:
```Delphi
  TgoRemoteNotificationMessage = class(TMessage)
  public
    constructor Create(const ADataKey, AJson: String; const AActivated: Boolean);
    property DataKey: String read FDataKey;
    property Json: String read FJson;

    { Whether message is activated by the user (tapping in it) }
    property Activated: Boolean read FActivated;
  end;
```
Since we are receiving a JSON payload for both Android and iOS we can examine the content here.  This is useful is we want to include our own custom content in the payload that is app specific.  See our [article on sending remote push notifications](https://blog.grijjy.com/2017/01/18/sending-ios-and-android-remote-push-notifications-from-your-delphi-service-with-the-http2-protocol/) for a discussion about customizing the payload.

If your device token changes on Android or iOS, the following TMessage is fired:
```Delphi
  { Device token change message }
  TgoDeviceTokenChangeMessage = class(TMessage)
  private
    FDeviceToken: String;
  public
    constructor Create(const ADeviceToken: String);
    property DeviceToken: String read FDeviceToken;
  end;
```
The above message is fired initially when you device token is assigned after app startup.  Due to the variances in the way device tokens are handled on iOS and Android this event could be immediate or delayed by the operating system.  

As a developer you should also be prepared that the device token could change if your application is reinstalled, the operating system is updated as well as dynamically while your app is active. 

# Apple APNS quirks
On iOS Remote Push notification events are received only when your application is in the foreground or background.  If your application is "force quit" also known as "terminated" then you cannot receive remote push notification events into your app.  Instead when the push notification arrives on screen and is pressed your app is launched but without receiving a notification event.

> Note: You only receive a single remote notification event at a time, meaning that if there are several events queued, the only one you receive is the one that the user clicked on in the iOS user interface.

iOS 8.x introduces a new approach called the PushKit which has the ability to silently launch your app into the background state.  We will explore this in a future article.

# Hello World for push notifications
To get started using the helper class, you will need your Android API Key for Firebase Cloud Messaging.

```Delphi
RemotePushReceiver := TgrRemotePushReceiver.Create(MyAndroidApiKey);
```
To subscribe to remote push notifications:
```Delphi
TMessageManager.DefaultManager.SubscribeToMessage(TgoRemoteNotificationMessage, RemoteNotificationHandler);
```

```Delphi
procedure TMyClass.RemoteNotificationHandler(const Sender: TObject;
  const Msg: TMessage);
var
  RemoteNotificationMessage: TgrRemoteNotificationMessage;
  Doc: TgoBsonDocument;
begin
  Assert(Assigned(Msg));
  Assert(Msg is TgoRemoteNotificationMessage);
  RemoteNotificationMessage := Msg as TgoRemoteNotificationMessage;
  { The user tapped this push notification, which resulted in the bringing the app to the
	foreground? }
  if (RemoteNotificationMessage.Activated) then
    Doc := TgrBsonDocument.Parse(RemoteNotificationMessage.Json);
end;
```
You will receive an Activated set to True if the notification is the likely result of a end-user actually pressing the notification.

To subscribe to device token changes:
```Delphi
TMessageManager.DefaultManager.SubscribeToMessage(TgoDeviceTokenChangeMessage, DeviceTokenChangeListener);
```

```Delphi
procedure TMyClass.DeviceTokenChangeListener(const Sender: TObject;
  const M: TMessage);
var
  DeviceTokenChangeMessage: TgoDeviceTokenChangeMessage;
begin
  DeviceTokenChangeMessage := M as TgoDeviceTokenChangeMessage;
  Writeln('Device Token is ' + DeviceTokenChangeMessage.DeviceToken);
end;
```

> Make sure you unsubscribe all the various TMessage listeners when you are completed. 

# Conclusion
Receiving remote push notifications in Delphi apps for Android and iOS is relatively straightforward with this helper class.  In the end, all you need to know is the device token in order to send a message to a device.

# License

TgoRemotePushReceiver is licensed under the Simplified BSD License. See License.txt for details.