# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 6.2.20
#### Added
- Added callback to initialize method needed for React Native. This change should have no effect for iOS SDK.

## 6.2.19
#### Added
- When using the inbox feature in popup mode, the method of modal transition can now be specified through  `popupModalPresentationStyle`

## 6.2.18
#### Fixed
- Users who were already set to the SDK will now always request a JWT (if enabled) whenever a user is set to the SDK

## 6.2.17
#### Fixed
- Added a call to get in-app messages after a JWT retrieval when setting the user to the Iterable SDK instance
- Fixed passing along deep links from the React Native SDK initialization

## 6.2.16
#### Fixed
- SDK initialization fix for React Native. Push notifications and deep links were not working for React Native when app is not in memory.

## 6.2.15
#### Fixed
- Removed specific plist files from the SPM targets to stop unnecessary warnings

## 6.2.14
#### Added
- Added in-app animations

#### Fixed
- Fixed non-inbox in-apps showing up in the inbox if multiple were about to be shown

## 6.2.13
#### Fixed
- Made `IterablePushNotificationMetadata` struct public.
- Optimized auth token refresh.
- Use `systemBackground` color for iOS 14.

## 6.2.12
#### Added
- Added authentication support

## 6.2.12-beta1
#### Added
- Added authentication support

## 6.2.11
#### Added
- Xcode 12 and iOS 14 support.

#### Fixed
- Fixed minor warnings.

## 6.2.10
#### Added
- An option to pause automatic in-app displaying has been added. To pause, set `IterableAPI.inAppManager.isAutoDisplayPaused` to `true` (default: `false`).

## 6.2.9
#### Fixed
- In rare instances `regiserDeviceToken` API can cause crash. This should fix it.

## 6.2.8
#### Added
- In-app messages now get "pre-loaded" with a timer (or until the in-app loads) to mitigate seeing the loading of the message

#### Fixed
- The JSON payload is now checked to be a valid JSON object before serialization
- Some classes that were intended for internal framework usage only have been assigned proper permission levels (thanks, made2k!)
- The root view controller is now correctly found on projects that are newly created in iOS 13
- `nil` is properly returned when deep linking encounters an error

## 6.2.7
#### Added
- Added internal `deviceAttributes` field for compatibility

## 6.2.6
#### Notes
- This SDK release is based off of 6.2.4, as 6.2.5 had some framework specific code that we don't believe has any user impact, but out of caution, is omitted from this release, and has the noted fixes below.

#### Fixed
- Action buttons now show properly when a mediaURL isn't specified
- The `trackEvent` event is now named accordingly
- Fixed the `campaignId` data type within our SDK (thanks, nkotula!)

## 6.2.5
#### Fixed
- Fixed the `campaignId` data type within our SDK (thanks, nkotula!)

## 6.2.4
#### Fixed
- Properly attribute the source of in app closes

## 6.2.3
#### Added
- `IterableInAppManagerProtocol` has been given `getMessage(withId id: String)` (Objective-C: `@objc(getMessageWithId:)`)

#### Fixed
- For Objective-C apps, `IterableLogDelegate.log` has had a typo fixed; the new signature is `@objc(log:message:)`
- For Objective-C apps, `IterableAPI.updateSubscriptions` has had a typo fixed; the new signature is `@objc(updateSubscriptions:unsubscribedChannelIds:unsubscribedMessageTypeIds:subscribedMessageTypeIds:campaignId:templateId:)`

## 6.2.2
#### Fixed
- Moved podspec `resources` to `resource_bundles` to avoid name collisions for static libraries (thanks, iletch!)
- Give `LogLevel` an Objective-C specific name (`IterableLogLevel`) (thanks, osawhoop!)

## 6.2.1
#### Fixed
- Made class extensions internal rather than public to avoid collisions (thanks, RolandasRazma!)

## 6.2.0
#### Added
- Moved Mobile Inbox support to GA (no longer in beta), and:
    - Added support for various ways to customize the default interface for a mobile inbox
    - Added a sample project that demonstrates how to customize the default interface for a mobile inbox
    - Added tracking for inbox sessions (when the inbox is visible in the app) and inbox message impressions (when a individual message's item is visible in the mobile inbox message list)
- Added support for Swift Package Manager

#### Deprecated
Please see each method's source code documentation for details.
- `IterableAPI.track(inAppOpen messageId: String)`
- `IterableAPI.track(inAppClick messageId: String, buttonURL: String)`

## 6.1.5
#### Fixed
- Fixed in-apps where display types that were not `fullScreen` were not displaying properly or becoming unresponsive.

## 6.1.4
#### Fixed
- Fixed the function signature of the `updateSubscriptions` call (thanks, Conor!)
- Fixed `NoneLogDelegate` not being usable for `IterableConfig.logDelegate` (thanks, katebertelsen!)

## 6.1.3
#### Changed
- Converted a log message variable to be interpreted as an UTF8 String (thanks, chunkyguy!)
- Enabled `BUILD_LIBRARY_FOR_DISTRIBUTION` for better compatibility across development environments

## 6.2.0-beta1
#### Added
- [Mobile Inbox](https://github.com/Iterable/swift-sdk/#mobile-inbox)
- [Mobile Inbox related events](https://github.com/Iterable/swift-sdk/#mobile-inbox-events-and-the-events-lifecycle)

#### Removed
- `IterableAPI.spawnInAppNotification(_:)`
    - In-app messages are automatically shown by SDK now. Please check our [migration guide](https://github.com/iterable/swift-sdk/#migrating-in-app-messages-from-the-previous-version-of-the-sdk).
- `IterableAPI.get(inAppMessages:)`
    - Use `IterableAPI.inAppManager.getMessages()` instead

#### Changed
 - There is no need to set `IterableConfig.pushIntegrationName` for new projects.

#### Deprecated
Please see method documentation for details about how to replace them.
- `IterableAPI.inAppConsume(messageId:)`
- `IterableAPI.showSystemNotification(..)`
- `IterableAPI.getAndTrack(deeplink:callbackBlock:)`

## 6.1.2
#### Fixed
- Fixed a bug in token to hex conversion code.

## 6.1.1
#### Changed
- Use `WKWebView` instead of deprecated class `UIWebView`.
- Migrated all Objective-C code to Swift.

## 6.2.0-dev1
#### Added
- Inbox
    - Brand new inbox functionality. Please see documentation for more details.

## 6.1.0
#### Changed
- In this version we have changed the way we use in-app notifications. In-app messages are now being sent asynchronously and your code can control the order and time in which an in-app notification will be shown. There is no need to poll for new in-app messages. Please refer to the **in-app messages** section of README file for how to use in-app messages. If you are already using in-app messages, please refer to [migration guide](https://github.com/iterable/swift-sdk#migrating-from-a-version-prior-to-610) section of README file.

## 6.1.0-beta4
#### Changed
- Url scheme `iterable://` is reserved for Iterable internal actions. In an earlier beta version, the reserved url scheme was `itbl://` but we are not using that now. `itbl://` scheme is only there for backward compatibility and should not be used.
- Url scheme `action://` is for user custom actions.

## 6.1.0-beta3
#### Changed
- Increase number of in-app messages fetched from the server to 100.

## 6.1.0-beta2
#### Added
- Support for `action://your-custom-action-name` URL scheme for calling custom actions 
    - For example, to have `IterableCustomActionDelegate` call a custom `buyCoffee` action when a user taps on an in-app message's **Buy** button.
- Support for reserved `itbl://sdk-custom-action` scheme for SDK internal actions.
    - URL scheme `itbl://sdk-custom-action` is reserved for internal SDK actions. Do not use it for custom actions. 
    - For example, future versions of the SDK may allow buttons to call href `itbl://delete` to delete an in-app message.

#### Fixed
- Carthage support with Xcode 10.2
- Xcode 10.2 Warnings
- URL Query parameters encoding bug

## 6.1.0-beta1
#### Added
- We have improved the in-app messaging implementation significantly. 
    - The SDK now maintains a local queue and keep it in sync with the server-side queue automatically.
    - Iterable servers now notify apps via silent push messages whenever the in-app message queue is updated.
    - In-app messages are shown by default whenever they arrive.
- It should be straightforward to migrate to the new implementation. There are, however, some breaking changes. Please see [migration guide](https://github.com/iterable/swift-sdk#Migrating-in-app-messages-from-the-previous-version-of-the-SDK) for more details.

#### Removed
- `spawnInAppNotification` call is removed. Please refer to migration guide mentioned above.

#### Changed
- You can now use `updateEmail` if the user is identified with either `email` or `userId`. Earlier you could only call `updateEmail` if the user was identified by `email`.
- The SDK now sets `notificationsEnabled` flag on the device to indicate whether notifications are enabled for your app.

#### Fixed
- nothing yet

## [6.0.8](https://github.com/Iterable/swift-sdk/releases/tag/6.0.8)
#### Fixed
- Carthage support with Xcode 10.2

## [6.0.4](https://github.com/Iterable/swift-sdk/releases/tag/6.0.4)
#### Added
- More refactoring and tests.

#### Changed
- Now we do not call createUserForUserId when registering device. This is handled on the server side.

#### Fixed
- `destinationUrl` was not being returned correctly from the SDK when using custom schemes for inApp messages.


## [6.0.3](https://github.com/Iterable/swift-sdk/releases/tag/6.0.3)
#### Added
- Call createUserForUserId when registering a device with userId
- Refactoring and tests.


## [6.0.2](https://github.com/Iterable/swift-sdk/releases/tag/6.0.2)
#### Added
- You can now set `logHandler` in IterableConfig.
- Now you don't have to call `IterableAPI.registerToken` on login/logout.


#### Fixed
- Don't show in-app message if one is already showing.


## [6.0.1](https://github.com/Iterable/swift-sdk/releases/tag/6.0.1)

#### Fixed
- Fixed issue that affects clients who are upgrading from Objective C Iterable SDK to Swift SDK. If you have attribution info stored in the previous Objective C SDK, it was not being deserialized in Swift SDK.
