# VCS Realtime SDK Sample App for iOS

<img src="https://user-images.githubusercontent.com/5943844/122239625-169d8800-ce8f-11eb-903c-75c5add95f93.jpeg" width="100" />

This sample app uses the Virtual Care Service (VCS) Realtime iOS SDK to demonstrate how to join virtual rooms and interact with other participants via audio and/or video.

## Create the Sample Application

To create the sample app, open the ```RealtimeSDKDemo.xcodeproj``` file in the ```examples/RealtimeSDKDemo``` directory with Xcode and perform the following steps:

#### Step 1

Remove RealtimeSDK.framework from the Frameworks folder

#### Step 2

In the RealtimeSDKDemo target, change the Team and Bundle Identifier to the appropriate values for your development environment.

#### Step 3

Include the following dependent Swift packages manually:

##### RealtimeSDK

```html
https://github.com/ATOS-VIRTUAL-CARE/realtime-sdk-ios
```

##### WebRTC

```html
https://github.com/ATOS-VIRTUAL-CARE/WebRTC
```

##### Apollo for iOS

```html
https://github.com/ATOS-VIRTUAL-CARE/apollo-ios
```

As part of the apollo-ios package installation, include the following package products:

* Apollo
* ApolloCore
* ApolloWebSocket

### Build and Run

Build the app and run on a device or the simulator. Note that the simulator does not provide video.

### More Information

See the following for more information on using the iOS SDK:

https://sdk.virtualcareservices.net/sdks/ios/
