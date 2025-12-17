# Flutter Torrent Streamer

A Flutter plugin that enables real-time BitTorrent streaming using a Go backend. This plugin allows you to stream video files directly from magnet links without waiting for the full download.

## Features

- **Real-time Streaming**: Start watching videos immediately while downloading.
- **Go Backend**: High-performance P2P engine powered by `anacrolix/torrent`.
- **Cross-Platform**: Ready for Android (ARM64 & x86_64).
- **Zero Config**: Pre-compiled shared libraries included.

## Getting Started

1. Add this package to your `pubspec.yaml`.
2. Ensure your Android app has Internet permission and allows Cleartext traffic (for local streaming server).

### Android Setup

In `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application
    ...
    android:usesCleartextTraffic="true"
    ...>
```

## Usage

```dart
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';
import 'package:path_provider/path_provider.dart';

// Start streaming
final tempDir = await getTemporaryDirectory();
final savePath = '${tempDir.path}/downloads';
await Directory(savePath).create(recursive: true);

String streamUrl = await FlutterTorrentStreamer.startStream(
  'magnet:?xt=urn:btih:...', 
  savePath
);

// Play streamUrl with your favorite video player!

// Stop streaming
await FlutterTorrentStreamer.stop();
```

## Architecture

- **Dart**: Handles MethodChannel/FFI and UI logic.
- **Go**: Runs as a shared library (`.so` on Android), managing the BitTorrent client and HTTP server.

## Building from Source (Optional)

If you want to modify the Go backend:

1. Go to the `go/` directory.
2. Run `go build -buildmode=c-shared -o ../android/src/main/jniLibs/arm64-v8a/libtorrent_streamer.so .`
