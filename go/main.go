package main

/*
#include <stdlib.h>
*/
import "C"
import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"
	"unsafe"

	"github.com/anacrolix/torrent"
)

type StreamStatus struct {
    Progress float64 `json:"progress"`
    Peers    int     `json:"peers"`
    Downloaded int64 `json:"downloaded"`
    Total      int64 `json:"total"`
    State      string `json:"state"`
    DownloadSpeed int64 `json:"downloadSpeed"` // Not directly available but good to have struct field
}

var (
	client     *torrent.Client
	mu         sync.Mutex
	serverPort int
	server     *http.Server
)

func initClient(savePath string) error {
	mu.Lock()
	defer mu.Unlock()
	if client != nil {
		return nil
	}
	cfg := torrent.NewDefaultClientConfig()
    if savePath != "" {
	    cfg.DataDir = savePath
    } else {
        // Fallback to temp dir
        cfg.DataDir = filepath.Join(os.TempDir(), "flutter_torrent_streamer")
    }
	os.MkdirAll(cfg.DataDir, 0755)
    
	// Disable upload for now to be safe/simple
	cfg.NoUpload = true
    // Enable debug logging to stdout (captured by logcat)
    // cfg.Debug = true 
	
	var err error
	client, err = torrent.NewClient(cfg)
	if err != nil {
		return err
	}

	// Start HTTP server
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return err
	}
	serverPort = listener.Addr().(*net.TCPAddr).Port

	mux := http.NewServeMux()
	mux.HandleFunc("/stream", streamHandler)
	
	server = &http.Server{
		Handler: mux,
	}
	
	go func() {
		if err := server.Serve(listener); err != nil && err != http.ErrServerClosed {
			fmt.Printf("HTTP server error: %v\n", err)
		}
	}()
	
	return nil
}

func streamHandler(w http.ResponseWriter, r *http.Request) {
	hashStr := r.URL.Query().Get("hash")

	if client == nil {
		http.Error(w, "Client not initialized", http.StatusInternalServerError)
		return
	}

    var t *torrent.Torrent
    for _, tor := range client.Torrents() {
        if tor.InfoHash().HexString() == hashStr {
            t = tor
            break
        }
    }

    if t == nil {
        http.Error(w, "Torrent not found", http.StatusNotFound)
        return
    }

	var largestFile *torrent.File
	var maxSize int64
	for _, f := range t.Files() {
		if f.Length() > maxSize {
			maxSize = f.Length()
			largestFile = f
		}
	}
    
    if largestFile == nil {
        http.Error(w, "File not found", http.StatusNotFound)
        return
    }
    
    largestFile.Download()
    
    reader := largestFile.NewReader()
    reader.SetResponsive()
    defer reader.Close()
    
    http.ServeContent(w, r, largestFile.Path(), time.Now(), reader)
}

//export GetStreamStatus
func GetStreamStatus() *C.char {
	if client == nil {
        status := StreamStatus{State: "Stopped"}
        b, _ := json.Marshal(status)
		return C.CString(string(b))
	}
    
    // Just get the first torrent for now as we only support single stream in this simple example
    torrents := client.Torrents()
    if len(torrents) == 0 {
        status := StreamStatus{State: "Idle"}
        b, _ := json.Marshal(status)
        return C.CString(string(b))
    }
    t := torrents[0]
    
    stats := t.Stats()
    status := StreamStatus{
        Progress: float64(t.BytesCompleted()) / float64(t.Length()) * 100,
        Peers: stats.ActivePeers,
        Downloaded: t.BytesCompleted(),
        Total: t.Length(),
        State: "Downloading",
    }
    b, _ := json.Marshal(status)
    return C.CString(string(b))
}

//export StartStream
func StartStream(magnetLink *C.char, savePath *C.char) *C.char {
    path := ""
    if savePath != nil {
        path = C.GoString(savePath)
    }

    if err := initClient(path); err != nil {
        return C.CString("Error initializing client: " + err.Error())
    }

	magnet := C.GoString(magnetLink)
	t, err := client.AddMagnet(magnet)
	if err != nil {
		return C.CString("Error adding magnet: " + err.Error())
	}

	select {
	case <-t.GotInfo():
	case <-time.After(60 * time.Second):
		return C.CString("Timeout waiting for torrent info")
	}

    // Eagerly start downloading the largest file
	var largestFile *torrent.File
	var maxSize int64
	for _, f := range t.Files() {
		if f.Length() > maxSize {
			maxSize = f.Length()
			largestFile = f
		}
	}
    
    if largestFile != nil {
        largestFile.Download()
    }

    return C.CString(fmt.Sprintf("http://127.0.0.1:%d/stream?hash=%s", serverPort, t.InfoHash().HexString()))
}

//export StopClient
func StopClient() {
    mu.Lock()
    defer mu.Unlock()
    if client != nil {
        client.Close()
        client = nil
    }
    if server != nil {
        server.Close()
        server = nil
    }
}

//export FreeString
func FreeString(str *C.char) {
	C.free(unsafe.Pointer(str))
}

func main() {}
