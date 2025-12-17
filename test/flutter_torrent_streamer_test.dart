import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer_platform_interface.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTorrentStreamerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTorrentStreamerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterTorrentStreamerPlatform initialPlatform = FlutterTorrentStreamerPlatform.instance;

  test('$MethodChannelFlutterTorrentStreamer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTorrentStreamer>());
  });

  test('getPlatformVersion', () async {
    FlutterTorrentStreamer flutterTorrentStreamerPlugin = FlutterTorrentStreamer();
    MockFlutterTorrentStreamerPlatform fakePlatform = MockFlutterTorrentStreamerPlatform();
    FlutterTorrentStreamerPlatform.instance = fakePlatform;

    expect(await flutterTorrentStreamerPlugin.getPlatformVersion(), '42');
  });
}
