//
//  ContentView.swift
//  SampleHaptics
//
//  Created by 齋藤修 on 2021/05/05.
//

import SwiftUI

struct ContentView: View {
    // UI表示に必要なパラメーター
    @State private var bpm: Int = 60
    @State private var isPlaying: Bool = false
    
    // コントローラーのインスタンス
    private var hapticController = HapticController()
    
    var body: some View {
        VStack {
            Text("BPM")
                .font(.system(size: 20))
            
            // BPMを表示
            Text(String(bpm))
                .font(.system(size: 68))
            
            // "+"ボタン: タップするとBPMを1増やす
            Button(action: {
                    self.bpm += 1
            }, label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60.0, height: 60.0)
            })
            .disabled(isPlaying)
            
            // 再生・停止ボタン
            if isPlaying == false {
                Button(action: {
                    hapticController.bpm = Double(self.bpm)
                    hapticController.play()
                    isPlaying = true
                }) {
                    Text("Start")
                        .font(.system(size: 60))
                }
            } else {
                Button(action: {
                    hapticController.stop()
                    isPlaying = false
                }) {
                    Text("Stop")
                        .font(.system(size: 60))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
