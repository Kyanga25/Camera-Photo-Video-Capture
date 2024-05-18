//
//  ViewModelCamera.swift
//  Camera
//
//  Created by Nathanael Mukyanga on 2024-04-05.
//

import SwiftUI
import AVFoundation
import Photos

class ViewModelCamera: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    var session = AVCaptureSession()
    public var currentCamera: AVCaptureDevice?
    public var currentCameraInput: AVCaptureDeviceInput?
    public var movieFileOutput: AVCaptureMovieFileOutput?
    public let captureDevice = AVCaptureDevice.default(for: .video)
    @Published public var model = Model(recording: false, switcher:.photo, isOn: false,zoomImage:1.0, saveAnimation: false,frontLight: false,position:.front,capture: false, isPlaying: true)
    
    @Published public var player = AVPlayer()
    
    override init() {
        super.init()
        prepareSession()
    }
    
    private func prepareSession() {
        session.beginConfiguration()
        addVideoInput(devicePosition: .front)
        addPhotoOutput()
        addMovieFileOutput()
        session.commitConfiguration()
        DispatchQueue.global().async{
            self.session.startRunning()
        }
    }
    
    private func addVideoInput(devicePosition: AVCaptureDevice.Position) {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: devicePosition)
        guard let device = discoverySession.devices.first, let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            print("Could not add video input")
            return
        }
        session.addInput(input)
        currentCamera = device
        currentCameraInput = input
    }
    
    private func addPhotoOutput() {
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }
    
    private func addMovieFileOutput() {
        movieFileOutput = AVCaptureMovieFileOutput()
        if let movieFileOutput = movieFileOutput, session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
    }
    
    func updateZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = currentCamera else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Error updating zoom factor: \(error.localizedDescription)")
        }
    }
    
    func toggleCameraPosition() {
        session.beginConfiguration()
        session.removeInput(currentCameraInput!)
        
        let newCameraPosition: AVCaptureDevice.Position = currentCamera?.position == .front ? .back : .front
        addVideoInput(devicePosition: newCameraPosition)
        
        session.commitConfiguration()
        
        if newCameraPosition == .front {
            self.model.position = .front
        } else if newCameraPosition == .back {
            self.model.position = .back
            
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = session.outputs.first(where: { $0 is AVCapturePhotoOutput }) as? AVCapturePhotoOutput else { return }
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func startVideoRecording() {
        guard let movieFileOutput = self.movieFileOutput, !movieFileOutput.isRecording else { return }
        let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        movieFileOutput.startRecording(to: outputPath, recordingDelegate: self)
        print("Video StartRecording")
    }
    
    func stopVideoRecording() {
        guard let movieFileOutput = self.movieFileOutput, movieFileOutput.isRecording else { return }
        movieFileOutput.stopRecording()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), error == nil else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        DispatchQueue.main.async {
            self.model.capturedImageData = imageData
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil  else  {
            print("Error recording video: \(String(describing: error))")
            return
        }
        
        DispatchQueue.main.async {
            self.player = AVPlayer(url:outputFileURL)
            self.player.play() // Automatically start playing
            self.model.isPlaying = true
            self.model.videoFileURL = outputFileURL
        }
    }
}
