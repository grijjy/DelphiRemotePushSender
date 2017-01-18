# Sending iOS (and Android) remote push notifications from your Delphi service with the HTTP/2 protocol

In this article we are going to discuss how to make a base unifying class for sending remote push notifications from your service to both the iOS (Apple Push Notification Service) and Android (Firebase Cloud Messaging) as well as covering how to use the newer Apple HTTP/2 protocol interface for sending push notifications from Delphi.

# Introduction

If you are authoring a Delphi service for the cloud, you may have the need to send push notifications from your service to your client application.  There are various ways to accomplish this including using third-party BAAS providers or rolling your own interface with some of the established libraries.

In the past Apple used a custom TCP binary protocol to send messages to the APNS.  This was cumbersome and inflexible and had numerous pitfalls in determining whether your message was actually accepted by the interface.   Apple recently released a newer interface that uses HTTP/2.  The nice thing about this interface is, just like FCM it utilizes JSON for the payload of the protocol.  However, the protocol uses the newer HTTP/2 protocol and ALPN (Application-Layer Protocol Negotiation Extension, defined in RFC 7301) which is required in your SSL handshake.

One other advantage, Apple also increased the maximium size of the payload from 2K to 4K with the new HTTP/2 interface as of iOS 9 devices. 

We will show how to combine the [Grijjy scalable client socket library](https://blog.grijjy.com/2017/01/09/scalable-https-and-tcp-client-sockets-for-the-cloud) with the excellent [nghttp2](http://nghttp2.org) to solve both of these issues and transparently send push notifications to either Apple's APNS or Google's FCM from your Delphi service.

For more information about us, our support and services visit the [Grijjy homepage](http://www.grijjy.com) or the [Grijjy developers blog](http://blog.grijjy.com).

The example contained here depends upon part of our [Grijjy Foundation library](https://github.com/grijjy/GrijjyFoundation).

The source code and related example repository is hosted on GitHub at [https://github.com/grijjy/DelphiRemotePushSender](https://github.com/grijjy/DelphiRemotePushSender).

# nghttp2

Nghttp2 is a fairly established library for implementing the HTTP/2 protocol.  It handles all the compression and bitstreaming from ordinary HTTP to HTTP/2.

The HTTP/2 protocol and it's header compression are rather complex and evolving so it is probably best not to try and implement this ourselves.

One of the great things about nghttp2 is you can utilize it entirely with memory buffers so it is a good match for our own [scalable client socket classes](https://github.com/grijjy/DelphiScalableClientSockets) for Windows and Linux.  This way we get the benefit of HTTP/2 but we don't have to rely on another implementation of sockets for scaling up our service. 

## Building nghttp2

If you want to build the nghttp2 library for Windows to use in your Delphi application you will need to download the [latest source](https://github.com/nghttp2/nghttp2).  To build you can use Visual Studio or just [download the Visual Studio Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools).  You will also need to download and install [CMAKE](https://cmake.org/).

  1.  Download the latest nghttp2 source from https://github.com/nghttp2/nghttp2
  2.  Install CMAKE and the Build Tools for Visual Studio.
  3.  Run CMAKE followed by a period
	  `cmake .`
  4.  Run CMAKE to build the release version 
  	  `cmake --build . --config RELEASE`

## Delphi header translation
Once completed you will have a nghttp2.dll.  We will need our [conversion for the header file for Delphi](https://github.com/grijjy/DelphiRemotePushSender/Nghttp2.pas) so we can use the nghttp2 methods directly.

## Apple APNS & iOS Prerequisites
To use the `TgoRemotePushSender` class with Apple's Push Notification Service, we need to create a certificate and convert that certificate into 2 PEM files, one for the certificate and one the private key.  
 
There are quite a few primers on the Internet about how to create APNS certificates, so we will be brief here as it applies to our `TgoRemotePushSender` class.  

1. On iOS you must create a production certificate that is universal by selecting the option "Apple Push Notification service SSL (Sandbox & Production)" under Certificates in the developer portal. This certificate must be matched with the proper AppId.

2. You need to download and install the certificate into the Mac OSX Keychain.

3. You need to export the Apple Push Notification service certificate and private key as 2 separate files (cert.p12 and key.p12) from the Keychain application on OSX.  These can only be exported as .p12 files from the Keychain application.

To create PEM files we recommend using the OpenSSL binaries to convert as follows:
```shell
openssl pkcs12 -clcerts -nokeys -out APNS-cert.pem -in cert.p12
```
```shell
openssl pkcs12 -nocerts -out APNS-key-password.pem -in key.p12
```
To remove the password from the APNS-key-password.pem file:
```shell
openssl rsa -in APNS-key-password.pem -out APNS-key.pem
```
To test the certificate against the APNS interface to see if it works:
```shell
openssl s_client -connect gateway.push.apple.com:2195 -cert APNS-cert.pem -key APNS-key.pem
```
# TgoRemotePushSender

To use the `TgoRemotePushSender` class we need to know the Device Token for the target user's device.  You pass this value to the TgoRemotePushSender.Send method when sending your remote push notification.  This is true of both iOS and Android targets.

For Android you also need to specify the `TgoRemotePushSender.AndroidAPIKey`.  You can obtain an API Key by setting up cloud messaging on [Google's developer site](https://developers.google.com/cloud-messaging/).  This is also called the Server API Key under Firebase Cloud Messaging.

For iOS you need to specify the `TgoRemotePushSender.APNSKey` which is essentially your Bundle Identifier (ex: com.mycool.app).  You also need to apply the APNS certificate and private key .PEM files you previously created.
```Delphi
TgoRemotePushSender.APNSKey := 'com.mycool.app';
TgoRemotePushSender.APNSCertificate := TFile.ReadAllBytes(PathToCertificate.PEM);
TgoRemotePushSender.APNSKey := TFile.ReadAllBytes(PathToKey.PEM);
```
  
The structure of the class is fairly straightforward.  To send a remote push notification, call the Send method and provide the Device Token and also the Title and Message body for the payload.

```Delphi
  TgoRemotePushSender = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
  public
    { Send push notification }
    function Send(const APlatform: TOSVersion.TPlatform; const ADeviceToken: String;
      const ATitle, AMessage: String): Boolean;
  public
    { Android API Key for your app }
    property AndroidAPIKey: String read FAndroidAPIKey write FAndroidAPIKey;

    { iOS Certificate }
    property APNSCertificate: TBytes read FAPNSCertificate write FAPNSCertificate;

    { iOS Key }
    property APNSKey: TBytes read FAPNSKey write FAPNSKey;

    { iOS Topic }
    property APNSTopic: String read FAPNSTopic write FAPNSTopic;
  end;
```

> Note: You should create and reuse an instance of this class to avoid creating multiple connections to the push notification host.  One model would be to perform notifications in batches based upon time.  Apple warns about creating too many connections as a reason for blocking your service.

[An example application](https://github.com/grijjy/DelphiRemotePushSender) demonstrating how to use this class is available within our repository on GitHub.

# Sending custom user data

Now that both Apple and Google use JSON as their payload format, you can easily add your own custom JSON fields to the payload that are consistent with both platforms.  While we don't expose this directly in our class you can add additional content by simply expanding the JSON with your extra custom data.

# License

TgoRemotePushSender and DelphiRemotePushSender are licensed under the Simplified BSD License. See License.txt for details.