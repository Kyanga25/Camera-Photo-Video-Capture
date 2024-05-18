//
//  Model.swift
//  Camera
//
//  Created by Nathanael Mukyanga on 2024-04-05.
//

import SwiftUI

enum Switch{
    case photo,video
}
enum Position{
    case front,back
}
struct Model {
    var recording:Bool
    var capturedImageData:Data? = nil
    var videoFileURL:URL? = nil
    var switcher:Switch
    var isOn: Bool
    var zoomImage:CGFloat
    var saveAnimation:Bool
    var frontLight:Bool 
    var position:Position
    var capture:Bool 
    var isPlaying:Bool
    
}
