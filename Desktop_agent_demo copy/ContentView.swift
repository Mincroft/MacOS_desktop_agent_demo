//
//  ContentView.swift
//  Desktop_agent_demo
//
//  Created by 殷瑜 on 2024/7/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = ScreencaptureViewModel()
    
    var body: some View {
        VStack {
            
            ForEach(vm.images, id: \.self) { image in
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .onDrag({ NSItemProvider(object: image) })
                    .draggable(image)
                
            }
            
            HStack {
                Button("Make a area screenshot") {
                    vm.takeScreenshot(for: .area)
                }
                
                Button("Make a window screenshot") {
                    vm.takeScreenshot(for: .window)
                }
                
                Button("Make a full screenshot") {
                    vm.takeScreenshot(for: .full)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
