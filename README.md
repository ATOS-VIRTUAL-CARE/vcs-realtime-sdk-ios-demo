# VCS Realtime SDK Sample App for iOS

<img src="https://user-images.githubusercontent.com/5943844/122239625-169d8800-ce8f-11eb-903c-75c5add95f93.jpeg" width="100" />

This sample app uses the Virtual Care Service (VCS) Realtime iOS SDK to demonstrate how to join virtual rooms and interact with other participants via audio and/or video.

## Create the Sample Application

To create the sample app, clone this repository, then open the ```RealtimeSDKDemo.xcodeproj``` file in the ```examples/RealtimeSDKDemo``` directory with Xcode. Then perform the following steps:

#### Step 1

Remove VcsRealtimeSdk.framework from the Frameworks folder

#### Step 2

In the RealtimeSDKDemo target, change the Team and Bundle Identifier to the appropriate values for your development environment.

#### Step 3

Include the following dependent Swift packages manually:

##### RealtimeSDK

```html
https://github.com/ATOS-VIRTUAL-CARE/vcs-realtime-sdk-ios
```

##### WebRTC

```html
https://github.com/ATOS-VIRTUAL-CARE/webrtc-ios
```

##### Apollo for iOS

```html
https://github.com/ATOS-VIRTUAL-CARE/apollo-ios
```
Branch for apollo-ios package
```
graphql-transport-ws
```

**IMPORTANT**

For the apollo-ios package, be sure the ```graphql-transport-ws``` branch is selected, rather than a release version.

Also, when the Apollo package is imported, only select the following package products:

* Apollo
* ApolloAPI
* ApolloWebSocket

### Build and Run

Build the app and run on a device or the simulator. Note that the simulator does not provide video.

### More Information

Where to find more information about the VCS Realtime SDKs and APIs.

* For more information on the VCS SDK family, see the [VCS realtime SDK page](https://sdk.virtualcareservices.net/)
* For more information on the VCS iOS SDK, see the [guide for iOS realtime SDK](https://sdk.virtualcareservices.net/sdks/ios)
* A list of all APIs for the iOS SDK is available at the [reference API for iOS realtime SDK](https://sdk.virtualcareservices.net/reference/ios)
