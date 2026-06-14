//
        //
    //  Project: SwiftUIMacOSWebcam
    //  File: VideoPreviewView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    

import SwiftUI
import AVKit
import AVFoundation

// View for previewing and saving recorded videos
struct VideoPreviewView: View {
    let url: URL
    let onSave: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
       
        VStack{
            // Top toolbar with action buttons
            HStack{
                // Cancel button to discard video
                Button("Cancel"){
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                // Save button to save video to disk
                Button("Save to Files"){
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            
            .background(.ultraThinMaterial)
            
            // Video player to preview recorded video
            VideoPlayer(player: AVPlayer(url: url))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, minHeight: 450)
        
        
    }
}
