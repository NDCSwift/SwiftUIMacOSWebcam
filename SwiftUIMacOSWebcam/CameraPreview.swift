//
        //
    //  Project: SwiftUIMacOSWebcam
    //  File: CameraPreview.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    
import SwiftUI
import AVFoundation

// SwiftUI wrapper for AVCaptureVideoPreviewLayer
struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession
    
    // Creates the NSView with AVCaptureVideoPreviewLayer
    func makeNSView(context: Context) -> NSView {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        let view = NSView()
        
        // Fill entire frame while maintaining aspect ratio
        previewLayer.videoGravity = .resizeAspectFill
        
        // Allow layer to resize automatically
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        // Set the preview layer as the view's backing layer
        view.layer = previewLayer
        
        // Enable layer backing for the view
        view.wantsLayer = true
        return view
        

    }
    
    // Updates the NSView when SwiftUI state changes
    func updateNSView(_ nsView: NSView, context: Context) {
        // Update layer frame to match view bounds
        if let previewLayer = nsView.layer as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = nsView.bounds
        }
    }
    
    
}
