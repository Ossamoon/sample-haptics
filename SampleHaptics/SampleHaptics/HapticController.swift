//
//  HapticController.swift
//  SampleHaptics
//
//  Created by 齋藤修 on 2021/05/09.
//

import Foundation
import CoreHaptics
import AVFoundation

class HapticController {
    // メトロノームのパラメーター
    var bpm: Double = 120.0
    
    // オーディオセッション
    private var audioSession: AVAudioSession
    
    // 音声データに関わるパラメータ
    private let audioResorceNames = "sound"
    private var audioURL: URL?
    private var audioResorceID: CHHapticAudioResourceID?
    
    // HapticEngine
    private var engine: CHHapticEngine!
    
    // 端末がCore Hapticsに対応しているか
    private var supportsHaptics: Bool = false
    
    // HapticPatternPlayer(Advacedの方を利用していることに注意)
    private var player: CHHapticAdvancedPatternPlayer?
    
    // HapticEventのパラメーター
    private let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
    private let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
    private var hapticDuration: TimeInterval = TimeInterval(0.08)
    
    // AudioEventのパラメーター
    private let audioVolume = CHHapticEventParameter(parameterID: .audioVolume, value: 1.0)
    private var audioDuration: TimeInterval {
        TimeInterval(60.0 / bpm)
    }
    
    init(){
        // オーディオセッションの設定
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set and activate audio session category.")
        }
        
        //　端末がCore Hapticsに対応しているかを調べる
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        
        // 外部音源の取り込み
        if let path = Bundle.main.path(forResource: audioResorceNames, ofType: "mp3") {
            audioURL = URL(fileURLWithPath: path)
        } else {
            print("Error: Failed to find audioURL")
        }
        
        createAndStartHapticEngine()    //この関数は下で定義
    }
    
    // Engineの作成と開始
    private func createAndStartHapticEngine() {
        // 端末の対応を確認
        guard supportsHaptics else {
            print("This device does not support CoreHaptics")
            return
        }
        
        // オーディオセッションを渡してEngineを作成
        do {
            engine = try CHHapticEngine(audioSession: audioSession)
        } catch let error {
            fatalError("Engine Creation Error: \(error)")
        }
        
        // Engineをスタート
        do {
            try engine.start()
        } catch let error {
            print("Engin Start Error: \(error)")
        }
    }
    
    // メトロノームを再生
    func play() {
        // 端末の対応を確認
        guard supportsHaptics else { return }
        
        do {
            // Engineをスタート
            try engine.start()
            
            // HapticPatternを作成
            let pattern = try createPattern()   //この関数は下で定義
            
            // Playerを作成(Advacedの方を利用していることに注意)
            player = try engine.makeAdvancedPlayer(with: pattern)
            player!.loopEnabled = true
            
            // 再生
            try player!.start(atTime: CHHapticTimeImmediate)
            
        } catch let error {
            print("Haptic Playback Error: \(error)")
        }
    }
    
    // メトロノームを停止
    func stop(){
        // 端末の対応を確認
        guard supportsHaptics else { return }
        
        // 停止
        engine.stop()
    }
    
    // HapticPatternの作成
    private func createPattern() throws -> CHHapticPattern {
        do {
            var eventList: [CHHapticEvent] = []
            
            // 音源のResorceIDを取得
            audioResorceID = try self.engine.registerAudioResource(audioURL!)
            
            // eventListにHapticEventを加えていく
            eventList.append(CHHapticEvent(audioResourceID: audioResorceID!, parameters: [audioVolume], relativeTime: 0, duration: self.audioDuration))
            eventList.append(CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0))
            eventList.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: self.hapticDuration))
            
            
            // HapticPatternを生成し返す
            let pattern = try CHHapticPattern(events: eventList, parameters: [])
            return pattern
            
        } catch let error {
            throw error
        }
    }
}
