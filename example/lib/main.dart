import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

// Top-level function for compute
Future<String> _startStreamIsolate(Map<String, String> args) async {
  return await FlutterTorrentStreamer.startStream(args['magnet']!, args['path']!);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF009688), // Teal color from the image
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009688)),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _selectedMenu = '业务管理';

  void _onMenuSelect(String menu) {
    setState(() {
      _selectedMenu = menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Sidebar(
              selectedMenu: _selectedMenu,
              onMenuSelect: _onMenuSelect,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _selectedMenu == '业务管理' 
                  ? const TorrentStreamerPage()
                  : Center(child: Text('Page: $_selectedMenu', style: const TextStyle(fontSize: 24, color: Colors.grey))),
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final String selectedMenu;
  final ValueChanged<String> onMenuSelect;

  const Sidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF009688);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            height: 50,
            color: tealColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list, color: Colors.white),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_left, color: Colors.white, size: 16),
                    const Text(
                      '微应用群',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 16),
                  ],
                ),
                const Icon(Icons.keyboard_double_arrow_left, color: Colors.white),
              ],
            ),
          ),
          
          // Search
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '菜单搜索',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: tealColor),
                ),
              ),
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildRootItem('集成应用微应用群'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRootItem(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.business, size: 20, color: Color(0xFF5C6BC0)), // Icon looking like the blue folder/server
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
        _buildSubItem('河北特高压预警平台', [
          '系统管理',
          '操作日志',
          '业务管理',
        ]),
      ],
    );
  }

  Widget _buildSubItem(String title, List<String> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.folder_open, size: 18, color: Color(0xFF26A69A)), // Greenish folder
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
        ...children.map((child) => _buildLeafItem(child)).toList(),
      ],
    );
  }

  Widget _buildLeafItem(String title) {
    final isSelected = selectedMenu == title;
    const tealColor = Color(0xFF009688);

    return InkWell(
      onTap: () => onMenuSelect(title),
      child: Container(
        padding: const EdgeInsets.only(left: 66, top: 10, bottom: 10, right: 16),
        color: isSelected ? const Color(0xFFE0F2F1) : Colors.transparent, // Light teal bg for selection
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? tealColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.star, size: 16, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}

// Re-using the previous Torrent Streamer Logic here
class TorrentStreamerPage extends StatefulWidget {
  const TorrentStreamerPage({super.key});

  @override
  State<TorrentStreamerPage> createState() => _TorrentStreamerPageState();
}

class _TorrentStreamerPageState extends State<TorrentStreamerPage> {
  final TextEditingController _magnetController = TextEditingController(
    text: 'magnet:?xt=urn:btih:08ada5a7a6183aae1e09d831df6748d566095a10&dn=Sintel&tr=udp%3A%2F%2Fexplodie.org%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.empire-js.us%3A1337&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=wss%3A%2F%2Ftracker.btorrent.xyz&tr=wss%3A%2F%2Ftracker.fastcast.nz&tr=wss%3A%2F%2Ftracker.openwebtorrent.com&ws=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2F&xs=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2Fsintel.torrent',
  ); 
  
  String _status = 'Idle';
  String _torrentStatus = '';
  VideoPlayerController? _controller;
  bool _isLoading = false;
  Timer? _statusTimer;

  @override
  void dispose() {
    _statusTimer?.cancel();
    FlutterTorrentStreamer.stop();
    _controller?.dispose();
    super.dispose();
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
       if (Platform.isAndroid) {
         try {
           final jsonStr = FlutterTorrentStreamer.getStatus();
           try {
             final statusMap = json.decode(jsonStr) as Map<String, dynamic>;
             final state = statusMap['state'] ?? 'Unknown';
             
             if (state == 'Downloading') {
               final progress = statusMap['progress'] ?? 0.0;
               final peers = statusMap['peers'] ?? 0;
               final downloaded = statusMap['downloaded'] ?? 0;
               final total = statusMap['total'] ?? 0;
               final speed = statusMap['downloadSpeed'] ?? 0;
               
               String formatBytes(num bytes) {
                 if (bytes < 1024) return '${bytes.toInt()} B';
                 if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
                 return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
               }

               setState(() {
                 _torrentStatus = 'State: $state\n'
                     'Progress: ${progress.toStringAsFixed(1)}%\n'
                     'Peers: $peers\n'
                     'Downloaded: ${formatBytes(downloaded)} / ${formatBytes(total)}\n'
                     'Speed: ${formatBytes(speed)}/s';
               });
             } else {
               setState(() {
                 _torrentStatus = 'State: $state';
               });
             }
           } catch (e) {
             setState(() {
               _torrentStatus = jsonStr;
             });
           }
         } catch (e) {
           print('Error getting status: $e');
         }
       }
    });
  }

  Future<void> _startStream() async {
    setState(() {
      _isLoading = true;
      _status = 'Starting torrent server...';
      _torrentStatus = '';
    });

    _startStatusPolling();

    try {
      final magnet = _magnetController.text;
      String url;
      
      if (Platform.isAndroid) {
        final tempDir = await getTemporaryDirectory();
        final savePath = '${tempDir.path}/torrent_downloads';
        await Directory(savePath).create(recursive: true);
        
        final args = {'magnet': magnet, 'path': savePath};
        url = await compute(_startStreamIsolate, args);
      } else {
         throw UnsupportedError('Platform ${Platform.operatingSystem} not supported in this example build');
      }
      
      setState(() {
        _status = 'Stream ready: $url';
      });

      bool dataReady = false;
      if (Platform.isAndroid) {
        setState(() {
          _status = 'Waiting for data...';
        });
        
        int retries = 0;
        while (retries < 60) {
           await Future.delayed(const Duration(seconds: 1));
           try {
             final jsonStr = FlutterTorrentStreamer.getStatus();
             final statusMap = json.decode(jsonStr);
             final downloaded = statusMap['downloaded'] ?? 0;
             if (downloaded > 512 * 1024) { 
                dataReady = true;
                break;
             }
           } catch (_) {}
           retries++;
        }

        if (!dataReady) {
          setState(() {
            _status = 'Error: No data received after 60s.';
            _isLoading = false;
          });
          _stopStream();
          return;
        }
      }

      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          setState(() {
            _status = 'Playback Error: ${_controller!.value.errorDescription}';
          });
        } else if (_controller!.value.isBuffering) {
           setState(() {
            _status = 'Buffering...';
          });
        }
      });

      await _controller!.initialize();
      _controller!.play();
      
      setState(() {
        _status = 'Playing...';
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _stopStream() async {
    _statusTimer?.cancel();
    await FlutterTorrentStreamer.stop();
    
    _controller?.dispose();
    setState(() {
        _controller = null;
        _status = 'Stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('业务管理 - 视频流播放'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _magnetController,
              decoration: const InputDecoration(
                labelText: 'Magnet Link',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _startStream,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688), foregroundColor: Colors.white),
                  child: const Text('Play'),
                ),
                ElevatedButton(
                  onPressed: _stopStream,
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_status),
            if (_torrentStatus.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_torrentStatus, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: AspectRatio(
                aspectRatio: _controller?.value.isInitialized == true 
                    ? _controller!.value.aspectRatio 
                    : 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: _controller?.value.isInitialized == true
                      ? VideoPlayer(_controller!)
                      : Center(
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Icon(Icons.play_circle_outline, size: 64, color: Colors.white24),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
