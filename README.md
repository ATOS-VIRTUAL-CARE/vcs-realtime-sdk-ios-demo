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

Using Xcode version 14 is recommended for developing with the iOS SDK at this time.

Using Xcode, open the ```RealtimeSDKDemo.xcodeproj``` file in the ```examples/RealtimeSDKDemo``` directory. Then perform the following steps:

### Setup

- Remove VcsRealtimeSdk.framework from the Frameworks folder.

- Include the following dependent Swift packages manually:

```html
https://github.com/ATOS-VIRTUAL-CARE/vcs-realtime-sdk-ios
```

Once Xcode finds the package, select *Up to Next Major Version* for the Dependency Rule to get the latest version of the VCS SDK.

```html
https://github.com/ATOS-VIRTUAL-CARE/webrtc-ios
```

Once Xcode finds the package, select *Exact Version* for the Dependency Rule and select version 104.0.0.

```html
https://github.com/apollographql/apollo-ios
```

Once Xcode finds the apollo-ios package, select *Up to Next Major Version* for the Dependency Rule and select version 0.51.2.

When the Apollo package is imported, only select the following package products:

> * Apollo
> * ApolloAPI
> * ApolloWebSocket

- In the RealtimeSDKDemo target, change the Team and Bundle Identifier to the appropriate values for your development environment.
- Change the server address for your specific deployment in the RealtimeSDKSettings.swift file. If you are running the sample app locally, see the following link for more information about how to access the application: [Running the app locally](https://github.com/ATOS-VIRTUAL-CARE/vcs-realtime-sdk-web-demo/blob/9b1867c36e169db25e85454829fd03aed0391c33/README.md#running-the-app-locally).
```swift
class RealtimeSDKSettings {

    /// Application server provides room tokens and VCS domain name based on "Room name"  &  API key
    static let applicationServer = ""
    static let serverUsername = ""
    static let serverPassword = ""
}
```
It is also possible to enter these values from the demo app's settings screen. Include the http or https prefix when specifying the application server either in the RealtimeSDKSettings.swift file or on the settings screen.

### Running the application server locally

For development purposes, the demo application server may be run locally to provide access to a test system. See the sample application for web clients [Running application locally](https://github.com/ATOS-VIRTUAL-CARE/vcs-realtime-sdk-web-demo#running-application-locally) for instructions. The application server address to be configured in the mobile client will be the localhost's IP address and the port the application server is listening on. Also, "http://" must prefix the address when not using TLS.
Example address: http://192.168.1.232:3001

### Build and Run

Build the application and run on a device or the simulator. Note that the simulator does not provide video.

Once the application is running, do the following:

- Enter a name in the **Room name** field
- Enter a name in the **Your name** field (optional)
- Select the media type (Audio only/Video only/Audio and Video)
- Tap on **Create Room** to create and join the room
- From another client, join the room using the same room name

### More Information

Where to find more information about the VCS Realtime 
s and APIs.

* For more information on the VCS SDK family, see the [VCS realtime SDK page](https://sdk.virtualcareservices.net/)
* For more information on the VCS iOS SDK, see the [guide for iOS realtime SDK](https://sdk.virtualcareservices.net/sdks/ios)
* A list of all APIs for the iOS SDK is available at the [reference API for iOS realtime SDK](https://sdk.virtualcareservices.net/reference/ios)
