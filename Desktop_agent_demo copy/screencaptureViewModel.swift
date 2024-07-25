//
//  screencaptureViewModel.swift
//  Desktop_agent_demo
//
//  Created by 殷瑜 on 2024/7/23.
//

import SwiftUI

class ScreencaptureViewModel: ObservableObject {
    
    enum ScreenshotTypes {
        case full
        case window
        case area
        
        var processArguments: [String] {
            switch self {
            case .full:
                ["-c"]
            case .window:
                ["-ew"]
            case .area:
                ["-cs"]
            }
        }
    }
    
    @Published var images = [NSImage]()
    
    func takeScreenshot(for type: ScreenshotTypes) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        task.arguments = type.processArguments
        
        do {
            try task.run()
            task.waitUntilExit()
            getImageFromPasteboard()
        } catch {
            print("could not make a screenshot : \(error)")
        }
    }
    
    private func convertImageToPNGData(image: NSImage) -> Data? {
        
        // 从 NSImage 创建一个位图表示
        guard let tiffData = image.tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        // 使用位图生成 PNG数据
        let pngData = bitmapImageRep.representation(using: .png, properties: [:])
        return pngData
    }
    
    private func getImageFromPasteboard() {
        
        // 检查剪贴板里有没有符合指定类型的数据，这里是符合NSImage类支持的所有图像，如果没有就退出
         guard NSPasteboard.general.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return }
        print("支持的图片类型：\(NSImage.imageUnfilteredTypes)")
        
        // 如果从粘贴板成功获取到图像，则 image 被赋值为该图像对象；否则，方法直接返回，不继续执行后续代码
         guard let image = NSImage(pasteboard: NSPasteboard.general) else { return }
         
         if let pngData = convertImageToPNGData(image: image) {
             // 获取当前运行文件的目录
             let fileManager = FileManager.default
            
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let directoryPath = documentsDirectory.appendingPathComponent("imageFolder")
                let filePath = directoryPath.appendingPathComponent("image.png")
                
                //创建imageFolder
                if !fileManager.fileExists(atPath: directoryPath.path) {
                    do {
                        try FileManager.default.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: true, attributes: nil)
                        print("Directory created successfully at path: \(directoryPath)")
                    } catch {
                        print("Failed to create directory: \(error.localizedDescription)")
                    }
                }

                //储存image
                do {
                    try pngData.write(to: filePath)
                    print("Image saved successfully at \(filePath)")
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        
        }

         self.images.append(image)
     }
     
     
 }

