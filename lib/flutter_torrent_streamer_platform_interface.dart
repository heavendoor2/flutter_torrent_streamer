import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_torrent_streamer_method_channel.dart';

abstract class FlutterTorrentStreamerPlatform extends PlatformInterface {
  /// Constructs a FlutterTorrentStreamerPlatform.
  FlutterTorrentStreamerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTorrentStreamerPlatform _instance = MethodChannelFlutterTorrentStreamer();

  /// The default instance of [FlutterTorrentStreamerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTorrentStreamer].
  static FlutterTorrentStreamerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTorrentStreamerPlatform] when
  /// they register themselves.
  static set instance(FlutterTorrentStreamerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
