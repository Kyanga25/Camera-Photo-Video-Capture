//
//  ContentView.swift
//  Camera
//
//  Created by Nathanael Mukyanga on 2024-04-05.
//

import SwiftUI
import AVFoundation
import AVKit
import Photos




struct Camera: UIViewRepresentable {
    @Binding var session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.session = session
            layer.frame = uiView.bounds
        }
    }
}




struct ContentView: View {
    @StateObject private var vm = ViewModel()
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(.all)
            
            GeometryReader{  geo in
                VStack{
                    // Top
                    HStack(spacing:geo.size.width * 0.2){
                        Button(
                            action: {
                                
                                Task{
                                    await self.vm.save()
                                }
                                
                            },
                            label: {
                                VStack{
                                    Image(systemName:vm.model.saveAnimation ? "checkmark":"square.and.arrow.down.fill")
                                    Text("Save")
                                }
                                .foregroundStyle(vm.model.saveAnimation ? .green:.white)
                            }
                        )
                        .contentTransition(.symbolEffect(.replace))
                        
                        
                        
                        // Text("1:10:10")
                        if vm.model.switcher == .photo {
                            Text("\u{00B7}")
                                .font(.system(size:100))
                                .foregroundStyle(.red)
                            
                            
                        } else if vm.model.switcher == .video && vm.model.recording == true && vm.model.videoFileURL == nil {
                            Text(Date.now, style: .timer)
                                .foregroundStyle(.red)
                        } else if vm.model.recording == false || vm.model.videoFileURL != nil  {
                            Text("0:00")
                                .foregroundStyle(.red)
                        }
                        Button(
                            action: {
                                self.vm.model.isOn.toggle()
                            },
                            label: {
                                VStack{
                                    Image(systemName:vm.model.isOn ? "lightbulb":"lightbulb.slash")
                                    Text("Flash")
                                }
                                .foregroundStyle(.white)
                            }
                        )
                    }
                    
                    .position(x:geo.size.width * 0.5,y:geo.size.height * 0.05)
                    //    // Middle
                  
                        Camera(session: $vm.session)
                        .colorMultiply(vm.model.capturedImageData != nil || vm.model.videoFileURL != nil  ? .clear:.white)
                        .gesture(self.vm.gesture())
                        .frame(width :geo.size.width * 0.93,height:geo.size.height * 0.57)
                        .position(x:geo.size.width * 0.5,y:geo.size.height * 0.1)
                        .foregroundStyle(.red)
                    
                    
                    // Bottom
                    HStack(alignment:.top,spacing:geo.size.width * 0.07){
                        
                        Button(
                            action: {
                                self.vm.dismiss()
                            },
                            label: {
                                Image(systemName: vm.model.switcher == .video ? "livephoto.play":"livephoto")
                                    .font(.system(size: 30))
   
                            }
                        )
                        
                            .foregroundStyle(.white)
                            .alignmentGuide(.top){ _ in
                                -geo.size.height * 0.085
                            }
                            
                        
                        VStack(spacing:geo.size.height * 0.03){
                        
                        
                        HStack(){
                            Button(
                                action: {
                                    self.vm.model.switcher = .photo
                                    
                                },
                                label: {
                                    RoundedRectangle(cornerRadius: 5)
            .frame(width:geo.size.width * 0.17,height:geo.size.height * 0.035)
                                    
                                    
                                        .overlay(
                                            Text("Photo")
                                                .foregroundStyle(.black)
                                        )
                                }
                            )
                            
                            .foregroundStyle(.white)
                            
                            Button(
                                action: {
                                    self.vm.model.switcher = .video
                                    
                                },
                                label: {
                                    RoundedRectangle(cornerRadius: 5)
                        .frame(width:geo.size.width * 0.17,height:geo.size.height * 0.035)
                                        .overlay(
                                            Text("Video")
                                                .foregroundStyle(.black)
                                        )
                                }
                            )
                            
                            .foregroundStyle(.white)
   
                        }
                        
                        Button(
                            action: {
                                Task{
                                    await self.vm.light()
                                    await self.vm.capture()
                                    
                                }
                            },
                            label: {
                                Circle()
                            .frame(width:geo.size.width * 0.4,height:geo.size.height * 0.1)
            .foregroundStyle(.white)
                        .overlay(
                            Circle()
                                        
                            .stroke(.black,lineWidth:3)
                            .frame(width:geo.size.width * 0.3,height:geo.size.height * 0.08)
                            .overlay{
                            Text(vm.labelCapture())
                        .font(.system(size: 15))
                        .foregroundStyle(vm.colorCapture())
                                                
                                            }
                                        
                                        
                                    )
                                
                            }
                        )
                        
                        
                        
                        
                    }
                        
                        Button(
                            action: {
                              
                                self.vm.toggleCameraPosition()
                                
                                
                               
                            },
                            label: {
                              
                                    
                Image(systemName: "arrow.2.circlepath.circle")
                            .font(.system(size: 30))
                                    
                                
                            }
                        )
                        .foregroundStyle(.white)
                        .alignmentGuide(.top){ _ in
                            -geo.size.height * 0.085
                        }
       
                }
                    .position(x:geo.size.width * 0.5,y:geo.size.height * 0.2)
                
                    
                    
                }
           
                if vm.model.capturedImageData != nil || vm.model.videoFileURL != nil {
                    if let imageData = vm.model.capturedImageData,vm.model.switcher == .photo,
                       let uiImage = UIImage(data:imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width :geo.size.width * 0.93,height:geo.size.height * 0.57)
                            .position(x:geo.size.width * 0.5,y:geo.size.height * 0.45)
                        
                    } else if vm.model.switcher == .video  {
                    
                        
                        VideoPlayers(player:vm.player)
                        
                            .frame(width :geo.size.width * 0.93,height:geo.size.height * 0.57)
                           
                            .position(x:geo.size.width * 0.5,y:geo.size.height * 0.45)
                            .overlay(
                                Button(
                                    action: {
                                        self.vm.playPause()
   
                                    },
                                    label: {
                                      
                                        Image(systemName:vm.model.isPlaying ? "play.fill":"pause.fill")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 40))
                                        
                                        
                                    }
                                )
                            
                               
                            )
                      
                        
                        
                    }
                }
            }
           
            if vm.model.frontLight == true {
               Rectangle()
                    .ignoresSafeArea(.all)
                    .foregroundStyle(.white)
                
                
            }
            
        }
    }
    
    
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct VideoPlayers: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No need to update anything for this simple example.
    }
}
