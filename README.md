# 📷 macOS Webcam — AVFoundation + SwiftUI

A macOS SwiftUI app that accesses the webcam for live video preview and photo capture — using AVFoundation and a clean `CameraManager` abstraction.

---

## 🤔 What this is

This project shows how to access the Mac's built-in camera (or any connected webcam) from a SwiftUI macOS app. It uses AVFoundation's `AVCaptureSession` under the hood, with a `CameraManager` observable class managing the session lifecycle, and `NSViewRepresentable` bridges for the live preview and captured photo display.

## ✅ Why you'd use it

- **macOS-specific camera pattern** — `NSViewRepresentable` preview bridge that works correctly on macOS (different from iOS)
- **Photo capture included** — `PhotoPreviewView` displays captured stills immediately
- **Live video preview** — `VideoPreviewView` wraps `AVCaptureVideoPreviewLayer` for the live feed
- **Clean session management** — `CameraManager` handles start, stop, and device switching

## 📺 Watch on YouTube

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20the%20Tutorial-red?style=for-the-badge&logo=youtube)](https://youtu.be/mhXwGw6It54)

> This project was built for the [NoahDoesCoding YouTube channel](https://www.youtube.com/@NoahDoesCoding97). Subscribe for weekly SwiftUI tutorials.

---

## 🚀 Getting Started

### 1. Clone the Repo
```bash
git clone https://github.com/NDCSwift/SwiftUIMacOSWebcam.git
cd SwiftUIMacOSWebcam
```

### 2. Open in Xcode
Double-click `SwiftUIMacOSWebcam.xcodeproj`.

### 3. Set Your Development Team
**TARGET → Signing & Capabilities → Team**

### 4. Update the Bundle Identifier
Change `com.example.MyApp` to a unique identifier.

### 5. Run
Build for **My Mac** target. Camera access will be requested on first launch.

---

## 🛠️ Notes

- Add `NSCameraUsageDescription` to `Info.plist`
- Camera entitlement may be required for distribution — add **Camera** under Signing & Capabilities
- If you see a code signing error, check that Team and Bundle ID are set

## 📦 Requirements

- Xcode 15+
- macOS 14+
- No third-party dependencies
