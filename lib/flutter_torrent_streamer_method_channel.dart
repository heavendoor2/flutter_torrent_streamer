import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_torrent_streamer_platform_interface.dart';

/// An implementation of [FlutterTorrentStreamerPlatform] that uses method channels.
class MethodChannelFlutterTorrentStreamer extends FlutterTorrentStreamerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_torrent_streamer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
