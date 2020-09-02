# video_autoplay_list

Package to provide a list for auto-playing videos, like you find in facebook feeds. 
* Gives flexibility to use the video player widget individually without using the list.
* List auto-scrolls to next video, after current video completes. 

![video_autoplay_list gif](https://github.com/Hitesh822/video_autoplay_list/blob/master/assets/video_autoplay_list.gif)

## Get Started

First, add `video_autoplay_list` as a dependency in your pubspec.yaml file.

To allow your app to access video files by URL, add following lines:

### iOS

Add the following entry to your Info.plist file, located in `<project root>/ios/Runner/Info.plist`:

```
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
```

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```
    <uses-permission android:name="android.permission.INTERNET"/>
```

## Example

Please check the example tab above.

## Dependencies

This package uses `video_plater` pacakage. 
Check out [video_player](https://pub.dev/packages/video_player) for package specific installations and supported video formats.