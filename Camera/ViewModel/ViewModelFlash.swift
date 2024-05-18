//
//  ViewModelFlash.swift
//  Camera
//
//  Created by Nathanael Mukyanga on 2024-04-05.
//

import AVFoundation
import Photos

class ViewModelFlash:ViewModelCamera{

    func toggleFlashlight() {
        guard let device = captureDevice else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .off {
                    try device.setTorchModeOn(level: 1.0)
                    self.model.isOn = true
                } else {
                    device.torchMode = .off
                    self.model.isOn = false
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Error toggling flashlight: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadURL(){
        guard let url = model.videoFileURL else {return}
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:url)
        }) { saved, error in
          if saved {
            print("Successfully saved video to Photos.")
          } else if let error = error {
            print("Error saving video to Photos: \(error.localizedDescription)")
          }
        }
    }
    
    
    func downloadData(){
       
        
       // Data -> Photos
        guard let imageData = self.model.capturedImageData else {
            print("No image data available")
            return
        }

        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
        } completionHandler: { success, error in
            if success {
                print("Photo saved to Photos library")
            } else {
                print("Error saving photo to Photos library: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
  
    }
  
}

