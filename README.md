# VCS Realtime SDK Sample Application for iOS

<img src="https://user-images.githubusercontent.com/5943844/122239625-169d8800-ce8f-11eb-903c-75c5add95f93.jpeg" width="100" />

This repository provides a sample application written in Swift, using the Virtual Care Service (VCS) Realtime iOS SDK to demonstrate how to join virtual rooms and interact with other participants via audio and/or video. 

## How to Run the Sample Application

Perform the following steps to get started with the sample application

- [Clone](#clone-the-repository) - Clone the repository
- [Setup](#setup) - Set up the sample application to run on a device or simulator
- [Build and Run](#build-and-run) - Build and run the application
- [More Information](#more-information) - Where to find more information

### Clone the repository

```sh
git clone https://github.com/ATOS-VIRTUAL-CARE/vcs-realtime-sdk-ios-demo.git
cd vcs-realtime-sdk-ios-demo
```

Using Xcode, open the ```RealtimeSDKDemo.xcodeproj``` file in the ```examples/RealtimeSDKDemo``` directory. Then perform the following steps:

### Setup

- Remove VcsRealtimeSdk.framework from the Frameworks folder.

- Include the following dependent Swift packages manually:

```html
https://github.com/ATOS-VIRTUAL-CARE/vcs-realtime-sdk-ios
```

```html
https://github.com/ATOS-VIRTUAL-CARE/webrtc-ios
```

```html
https://github.com/ATOS-VIRTUAL-CARE/apollo-ios
```

When the Apollo package is imported, only select the following package products:

> * Apollo
> * ApolloAPI
> * ApolloWebSocket

- In the RealtimeSDKDemo target, change the Team and Bundle Identifier to the appropriate values for your development environment.
- If necessary, change the server addresses for your specific deployment. The demo application is already configured with the server at [VCS realtime SDK Demo](https://sdk-demo.virtualcareservices.net/)

### Build and Run

Build the application and run on a device or the simulator. Note that the simulator does not provide video.

### More Information

Where to find more information about the VCS Realtime SDKs and APIs.

* For more information on the VCS SDK family, see the [VCS realtime SDK page](https://sdk.virtualcareservices.net/)
* For more information on the VCS iOS SDK, see the [guide for iOS realtime SDK](https://sdk.virtualcareservices.net/sdks/ios)
* A list of all APIs for the iOS SDK is available at the [reference API for iOS realtime SDK](https://sdk.virtualcareservices.net/reference/ios)
