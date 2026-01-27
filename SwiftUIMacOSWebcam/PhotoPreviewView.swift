//
        //
    //  Project: SwiftUIMacOSWebcam
    //  File: PhotoPreviewView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    

import SwiftUI
import AVFoundation
import AVKit

// View for previewing and saving captured photos
struct PhotoPreviewView: View {
    let item: IdentifiableImage
    let onSave: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack{
            // Top toolbar with action buttons
            HStack{
                // Cancel button to discard photo
                Button("Cancel"){
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                // Save button to save photo to disk
                Button("Save to files"){
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Display captured photo
            Image(nsImage: item.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
            
        }
        .frame(minWidth: 600, minHeight: 450)
        
    }
}

