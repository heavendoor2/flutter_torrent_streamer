$NDK_PATH = "C:\Users\yyyy\AppData\Local\Android\Sdk\ndk\26.3.11579264"
$TOOLCHAIN = "$NDK_PATH\toolchains\llvm\prebuilt\windows-x86_64\bin"
$CC = "$TOOLCHAIN\aarch64-linux-android34-clang.cmd"

$env:CGO_ENABLED = "1"
$env:GOOS = "android"
$env:GOARCH = "arm64"
$env:CC = $CC

# Check if CC exists
if (-not (Test-Path $CC)) {
    Write-Host "Error: NDK Compiler not found at $CC"
    exit 1
}

Write-Host "Building for Android (arm64)..."
go build -buildmode=c-shared -o ../example/android/app/src/main/jniLibs/arm64-v8a/libtorrent_streamer.so .

if ($?) {
    Write-Host "Build Successful!"
} else {
    Write-Host "Build Failed!"
}
