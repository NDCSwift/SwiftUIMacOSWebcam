//
        //
    //  Project: SwiftUIMacOSWebcam
    //  File: CameraManager.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

import AVFoundation
import SwiftUI
import Combine

// Main class that manages camera operations, photo capture, and video recording
class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    // Called when video recording finishes
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        if let error = error {
            print("Recording error \(error.localizedDescription)")
            return
        }
        // Update UI on main thread
        DispatchQueue.main.async {
            [weak self] in
            self?.isRecording = false
            self?.recordedVideoURL = outputFileURL
        }
        
    }
    
    // MARK: - Published Properties
    
    // Stores captured photo for preview
    @Published var capturedImage: IdentifiableImage?
    
    // Indicates if the capture session is running
    @Published var isSessionRunning = false
    
    // List of all available cameras (built-in and external)
    @Published var availableCameras: [AVCaptureDevice] = []
    
    // Currently selected camera device
    @Published var selectedCamera: AVCaptureDevice?
    
    // Indicates if video is currently recording
    @Published var isRecording = false
    
    // URL of the recorded video file
    @Published var recordedVideoURL: URL?
    
    // MARK: - Private Properties
    
    // AVFoundation capture session
    let session = AVCaptureSession()
    
    // Output for capturing photos
    private let photoOutput = AVCapturePhotoOutput()
    
    // Output for recording videos
    private let videoOutput = AVCaptureMovieFileOutput()
    
    // Current camera input
    private var currentInput: AVCaptureDeviceInput?
    
    // Background queue for session operations
    private let sessionQueue = DispatchQueue(label: "com.macwebcam.sessionQueue")
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        discoverCameras()
    }
    
    // MARK: - Camera Discovery
    
    // Discovers all available cameras on the device
    private func discoverCameras(){
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        availableCameras = discoverySession.devices
        selectedCamera = availableCameras.first
    }
    
    // MARK: - Session Setup
    
    // Configures and starts the capture session
    func setupSession(){
        sessionQueue.async { [weak self] in
            guard let self = self, let camera = self.selectedCamera else { return }
            
            // Begin configuration
            self.session.beginConfiguration()
            
            // Remove existing inputs
            self.session.inputs.forEach { self.session.removeInput($0) }
            
            // Set session quality
            self.session.sessionPreset = .high
            
            // Create camera input
            guard let input = try? AVCaptureDeviceInput(device: camera) else {
                self.session.commitConfiguration()
                return
            }
            
            // Add camera input
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            // Add photo output
            if self.session.canAddOutput(self.photoOutput){
                self.session.addOutput(self.photoOutput)
            }
            
            // Add video output
            if self.session.canAddOutput(self.videoOutput){
                self.session.addOutput(self.videoOutput)
            }
            
            // Add audio input for video recording
            if let mic = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: mic){
                self.session.addInput(audioInput)
            }
            
            // Commit configuration and start session
            self.session.commitConfiguration()
            self.session.startRunning()
            
            // Update running status on main thread
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
            
            
            
        }
    }
    
    // MARK: - Photo Capture
    
    // Initiates photo capture
    func capturePhoto() {
        sessionQueue.async {
            [weak self] in
            
            guard let self = self else { return }
            
            // Create photo settings
            let settings = AVCapturePhotoSettings()
            
            // Trigger photo capture
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    // Called when photo processing is complete
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error = error {
            print("Capture error \(error.localizedDescription)")
            return
        }
        
        // Convert photo data to NSImage
        guard let imageData = photo.fileDataRepresentation(),
              let nsImage = NSImage(data: imageData) else {
            print("failed to convert the photo")
            return
        }
        
        // Store captured image on main thread
        DispatchQueue.main.async {
            [weak self] in
            
            self?.capturedImage = IdentifiableImage(image: nsImage)
        }
        
    }
    
    // MARK: - Save Photo
    
    // Saves a photo to disk using a save panel
    func savePhoto(_ image: NSImage) {
        sessionQueue.async {
            
            // Convert NSImage to PNG data
            guard let imageData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: imageData),
                  let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
                print("Failed to convert image to png")
                return
            }
            
            // Show save panel on main thread
            DispatchQueue.main.async {
                let panel = NSSavePanel()
                panel.allowedContentTypes = [.png]
                panel.nameFieldStringValue = "Photo.png"
                panel.canCreateDirectories = true
                
                // Save file if user confirms
                if panel.runModal() == .OK, let url = panel.url {
                    do{
                        try pngData.write(to: url)
                        // Reveal saved file in Finder
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    } catch {
                        print("Save error \(error.localizedDescription)")
                    }
                }
                
            }
            
        }
    }
    
    // MARK: - Video Recording
    
    // Starts video recording
    func startRecording(){
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            // Create temporary file URL for recording
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            
            // Start recording to temporary file
            self.videoOutput.startRecording(to: tempURL, recordingDelegate: self)
            
        }
    }
    
    // Saves recorded video to disk using a save panel
    func saveVideo(_ tempURL: URL) {
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.movie]
            panel.nameFieldStringValue = "Video.mov"
            panel.canCreateDirectories = true
            
            // Copy video to user-selected location if confirmed
            if panel.runModal() == .OK, let destinationURL = panel.url {
                do{
                    try FileManager.default.copyItem(at: tempURL, to: destinationURL)
                    
                    // Reveal saved video in Finder
                    NSWorkspace.shared.activateFileViewerSelecting([destinationURL])
                    
                    // Clean up temporary file
                    try? FileManager.default.removeItem(at: tempURL)
                }
                catch {
                    print("Video saved error \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Stops video recording
    func stopRecording(){
        sessionQueue.async {
            [weak self] in
            
            self?.videoOutput.stopRecording()
        }
    }
    
}
    

// MARK: - Helper Structs

// Wrapper to make NSImage identifiable for SwiftUI
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: NSImage
}

// Wrapper to make URL identifiable for SwiftUI
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}
