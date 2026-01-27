//
        //
    //  Project: SwiftUIMacOSWebcam
    //  File: ContentView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    
// Enum to define the capture mode (photo or video)
enum CaptureMode {
    case photo, video
}


import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    
    // Camera manager instance to handle camera operations
    @StateObject private var cameraManager = CameraManager()
    
    // Current capture mode state
    @State private var captureMode: CaptureMode = .photo
    
    // Duplicate enum definition (note: this duplicates the one above)
    enum CaptureMode {
        case photo, video
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Camera preview section
            if cameraManager.isSessionRunning {
                // Display live camera feed
                CameraPreview(session: cameraManager.session)
                    .frame(minWidth: 640, minHeight: 480)
                    .aspectRatio(4/3, contentMode: .fit)
            } else {
                // Display placeholder when camera is unavailable
                Rectangle()
                    .fill(.black)
                    .frame(minWidth: 640, minHeight: 480)
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "video.slash")
                                .font(.system(size: 48))
                                .foregroundStyle(.gray)
                            Text("Camera Not Available")
                                .foregroundStyle(.secondary)
                        }
                    }
            }
            
            // Controls toolbar at the bottom
            HStack(spacing: 16) {
                // Camera selection picker (only shown if multiple cameras available)
                if cameraManager.availableCameras.count > 1 {
                    Picker("Camera", selection: $cameraManager.selectedCamera) {
                        ForEach(cameraManager.availableCameras, id: \.uniqueID) { camera in
                            Text(camera.localizedName).tag(camera as AVCaptureDevice?)
                        }
                    }
                    .frame(width: 200)
                    // Reinitialize session when camera changes
                    .onChange(of: cameraManager.selectedCamera) { oldValue, newValue in
                        cameraManager.setupSession()
                    }
                }
                
                // Segmented picker to switch between photo and video mode
                Picker("Mode", selection: $captureMode) {
                    Text("Photo").tag(CaptureMode.photo)
                    Text("Video").tag(CaptureMode.video)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                
                Spacer()
                
                // Capture/Record button (changes based on mode)
                if captureMode == .photo {
                    // Photo capture button
                    Button {
                        cameraManager.capturePhoto()
                    } label: {
                        Label("Capture Photo", systemImage: "camera.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    // Video recording button (toggles between start/stop)
                    Button {
                        if cameraManager.isRecording {
                            cameraManager.stopRecording()
                        } else {
                            cameraManager.startRecording()
                        }
                    } label: {
                        Label(
                            cameraManager.isRecording ? "Stop Recording" : "Start Recording",
                            systemImage: cameraManager.isRecording ? "stop.circle.fill" : "record.circle"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(cameraManager.isRecording ? .red : .blue)
                }
                
                // Recording indicator (shown during video recording)
                if cameraManager.isRecording {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        Text("Recording")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .frame(minWidth: 800, minHeight: 600)
        // Initialize camera session when view appears
        .onAppear {
            cameraManager.setupSession()
        }
        // Show photo preview sheet after capturing
        .sheet(item: $cameraManager.capturedImage) { item in
            PhotoPreviewView(
                item: item,
                onSave: {
                    cameraManager.savePhoto(item.image)
                    cameraManager.capturedImage = nil
                },
                onDismiss: {
                    cameraManager.capturedImage = nil
                }
            )
        }
        // Show video preview sheet after recording
        .sheet(item: Binding(
            get: { cameraManager.recordedVideoURL.map { IdentifiableURL(url: $0) } },
            set: { cameraManager.recordedVideoURL = $0?.url }
        )) { item in
            VideoPreviewView(
                url: item.url,
                onSave: {
                    cameraManager.saveVideo(item.url)
                    cameraManager.recordedVideoURL = nil
                },
                onDismiss: {
                    cameraManager.recordedVideoURL = nil
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
