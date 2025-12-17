import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI signatures
typedef StartStreamFunc = Pointer<Utf8> Function(Pointer<Utf8> magnet, Pointer<Utf8> savePath);
typedef StartStream = Pointer<Utf8> Function(Pointer<Utf8> magnet, Pointer<Utf8> savePath);

typedef StopClientFunc = Void Function();
typedef StopClient = void Function();

typedef GetStreamStatusFunc = Pointer<Utf8> Function();
typedef GetStreamStatus = Pointer<Utf8> Function();

typedef FreeStringFunc = Void Function(Pointer<Utf8> str);
typedef FreeString = void Function(Pointer<Utf8> str);

class FlutterTorrentStreamer {
  static DynamicLibrary? _lib;

  static void _ensureInitialized() {
    if (_lib != null) return;

    try {
      if (Platform.isWindows) {
        // In debug mode, you might need to place the DLL in the build directory
        // or ensure it's in the PATH.
        // Try looking in the current directory first
        try {
          _lib = DynamicLibrary.open('torrent_streamer.dll');
        } catch (_) {
             // Fallback to expecting it next to the executable
             _lib = DynamicLibrary.open('torrent_streamer.dll');
        }
      } else if (Platform.isLinux) {
        _lib = DynamicLibrary.open('./libtorrent_streamer.so');
      } else if (Platform.isMacOS) {
        _lib = DynamicLibrary.open('libtorrent_streamer.dylib');
      } else if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libtorrent_streamer.so');
      } else {
        throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
      }
    } catch (e) {
      print('Failed to load dynamic library: $e');
      rethrow;
    }
  }

  /// Starts streaming the given magnet link.
  /// Returns a local HTTP URL to the stream, or an error message.
  /// 
  /// Note: This call blocks until the torrent info is downloaded (up to 60s).
  /// It is HIGHLY RECOMMENDED to call this method in a separate Isolate 
  /// (e.g. using Isolate.run) to avoid freezing the UI.
  static Future<String> startStream(String magnetLink, String savePath) async {
    _ensureInitialized();
    
    final startStream = _lib!
        .lookup<NativeFunction<StartStreamFunc>>('StartStream')
        .asFunction<StartStream>();
        
    final freeString = _lib!
        .lookup<NativeFunction<FreeStringFunc>>('FreeString')
        .asFunction<FreeString>();

    final magnetPtr = magnetLink.toNativeUtf8();
    final savePathPtr = savePath.toNativeUtf8();
    try {
      final resultPtr = startStream(magnetPtr, savePathPtr);
      final result = resultPtr.toDartString();
      
      freeString(resultPtr);
      
      return result;
    } finally {
      calloc.free(magnetPtr);
      calloc.free(savePathPtr);
    }
  }

  static Future<void> stop() async {
    _ensureInitialized();
    final stopClient = _lib!
        .lookup<NativeFunction<StopClientFunc>>('StopClient')
        .asFunction<StopClient>();
    stopClient();
  }

  static String getStatus() {
    _ensureInitialized();
    final getStatus = _lib!
        .lookup<NativeFunction<GetStreamStatusFunc>>('GetStreamStatus')
        .asFunction<GetStreamStatus>();
    
    final freeString = _lib!
        .lookup<NativeFunction<FreeStringFunc>>('FreeString')
        .asFunction<FreeString>();
        
    final resultPtr = getStatus();
    final result = resultPtr.toDartString();
    freeString(resultPtr);
    return result;
  }
}
