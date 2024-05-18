//
//  ViewModel.swift
//  Camera
//
//  Created by Nathanael Mukyanga on 2024-04-05.
//
import Foundation
import Foundation
import SwiftUI

class ViewModel:ViewModelFlash {

    func save() async {
        if model.capturedImageData != nil || model.videoFileURL != nil {
        
        if model.switcher == .photo {
            downloadData()
    
        } else if model.switcher == .video {
          downloadURL()
  
        }
       
            self.model.saveAnimation = true
            try! await Task.sleep(nanoseconds: 1_000_000_000)
            self.model.saveAnimation = false
            self.model.capturedImageData = nil
            self.model.videoFileURL = nil 
        }
        
    }
    func capture()async {
        
        if model.switcher == .photo  {
            
            try! await Task.sleep(nanoseconds:100_000_000)
            
           capturePhoto()
           
           
        } else if model.switcher == .video {
         //   self.model.recording.toggle()
            if model.recording == false  {
                startVideoRecording()
                self.model.recording = true
            } else {
                stopVideoRecording()
                self.model.recording = false 
            }
        }
   
    }
    func labelCapture()-> String {
        if model.switcher == .video {
            if model.recording == true   {
            return "Stop"
            
        } else  {
            
            return "Start"
        }
        } else  {
            return "Capture"
        }
        
    }
    
    
    func colorCapture()-> Color {
        if model.switcher == .video {
            if model.recording == true {
                return .red
            } else {
                return .blue
            }
        } else {
            return .blue
        }
    }
    
    func light() async {
       
        
        if model.switcher == .photo &&  model.position == .back && model.isOn == true  {
            toggleFlashlight()
            try! await Task.sleep(nanoseconds: 1_500_000_000)
            toggleFlashlight()
        } else if model.switcher == .photo && model.position == .front && model.isOn == true {
            model.frontLight = true
            try! await Task.sleep(nanoseconds: 1_500_000_000)
            model.frontLight = false 
            
        } else if model.switcher == .video && model.position == .back && model.isOn == true {
             toggleFlashlight()
         }
        
        
    }
  
 
    func playPause() {
        // Toggling the playback state based on the current state
        if model.isPlaying {
            player.pause()
        } else {
            player.play()
            player.seek(to:.zero)  // Ensure playback starts from the beginning if needed
        }
        model.isPlaying.toggle()  // Update the isPlaying flag to reflect the new state
    }

    
    
    
    func gesture()-> some Gesture{
        MagnificationGesture()
            .onChanged { value in
                let zoomValue = min(max(self.model.zoomImage * value, 1.0), 5.0) // Adjust zoom range as needed
                self.model.zoomImage = zoomValue
                self.updateZoomFactor(zoomValue) // Pass the zoom value to the recorder
            }
    }

    
    func dismiss(){
        if model.switcher == .photo{
            self.model.capturedImageData = nil
        } else {
            self.model.videoFileURL = nil
        }
       
        
    }
    
}
