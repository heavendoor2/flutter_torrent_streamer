# flutter_go_torrent_streamer

An **experimental Flutter demo plugin** that uses a Go backend (via `anacrolix/torrent`) to **demonstrate** real-time torrent video streaming to a video player.

> ⚠️ This project is a **proof of concept / experimental demo**.  
> It is intended for learning, exploration, and technical validation only, and is **not production-ready**.

---

## Architecture

This demo showcases a simple cross-language streaming pipeline:

- **Go**  
  Implements BitTorrent logic using `anacrolix/torrent`, performs progressive (sequential) downloading, and exposes a lightweight local HTTP server for streaming.

- **Dart (FFI)**  
  Demonstrates calling Go functions via FFI to start/stop the torrent session and retrieve a streamable HTTP URL.

- **Flutter**  
  Acts as a demo client that passes the stream URL to a video player for playback.

---

## Prerequisites

- **Go**: 1.21+  
- **Flutter**: 3.0+  
- **C Compiler**: GCC (Linux / Windows MinGW) or Clang (macOS)  
  Required to build the Go shared library for FFI.

---

## Setup

### 1. Build the Go Shared Library

This demo requires manually compiling the Go code into a shared library (`.dll`, `.so`, or `.dylib`) so it can be loaded by Dart FFI.

```bash
cd go
go mod tidy

# Windows (requires MinGW / GCC)
go build -buildmode=c-shared -o ../torrent_streamer.dll .

# Linux
# go build -buildmode=c-shared -o ../libtorrent_streamer.so .

# macOS
# go build -buildmode=c-shared -o ../libtorrent_streamer.dylib .
