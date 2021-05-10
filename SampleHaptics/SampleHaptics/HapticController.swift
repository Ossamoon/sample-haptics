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
    // Metronome Parameter:
    var bpm: Double = 120.0
    
    // Audio Session:
    private var audioSession: AVAudioSession
    
    // Audio Data:
    private let audioResorceNames = "sound"
    private var audioURL: URL?
    private var audioResorceID: CHHapticAudioResourceID?
    
    // Haptic Engine:
    private var engine: CHHapticEngine!
    
    // Haptic Support:
    var supportsHaptics: Bool = false
    
    // Haptic Player:
    var player: CHHapticAdvancedPatternPlayer?
    
    // Haptic Event Parameters:
    private let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
    private let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
    private var hapticDuration: TimeInterval = TimeInterval(0.08)
    
    // Audio Event Parameters:
    private let audioVolume = CHHapticEventParameter(parameterID: .audioVolume, value: 1.0)
    private var audioDuration: TimeInterval {
        TimeInterval(60.0 / bpm)
    }
    
    init(){
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set and activate audio session category.")
        }
        
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        
        if let path = Bundle.main.path(forResource: audioResorceNames, ofType: "mp3") {
            audioURL = URL(fileURLWithPath: path)
        } else {
            print("Error: Failed to find audioURL")
        }
        
        createAndStartHapticEngine()
    }
    
    private func createAndStartHapticEngine() {
        // Check for device compatibility
        guard supportsHaptics else {
            print("This device does not support CoreHaptics")
            return
        }
        
        // Create and configure a haptic engine.
        do {
            engine = try CHHapticEngine(audioSession: audioSession)
        } catch let error {
            fatalError("Engine Creation Error: \(error)")
        }
        
        // Start haptic engine to prepare for use.
        do {
            try engine.start()
        } catch let error {
            print("Engin Start Error: \(error)")
        }
    }
    
    func play() {
        // Check for device compatibility
        guard supportsHaptics else { return }
        
        do {
            // Start Engine
            try engine.start()
            
            // Create haptic pattern
            let pattern = try createPattern()
            
            // Create player
            player = try engine.makeAdvancedPlayer(with: pattern)
            player!.loopEnabled = true
            
            // Start player
            try player!.start(atTime: CHHapticTimeImmediate)
            
        } catch let error {
            print("Haptic Playback Error: \(error)")
        }
    }
    
    func stop(){
        guard supportsHaptics else { return }
        engine.stop()
    }
    
    private func createPattern() throws -> CHHapticPattern {
        do {
            var eventList: [CHHapticEvent] = []
            
            // Register audio resources
            audioResorceID = try self.engine.registerAudioResource(audioURL!)
            
            // Add events to eventList
            eventList.append(CHHapticEvent(audioResourceID: audioResorceID!, parameters: [audioVolume], relativeTime: 0, duration: self.audioDuration))
            eventList.append(CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0))
            eventList.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: self.hapticDuration))
            
            
            // Create and Return the pattern
            let pattern = try CHHapticPattern(events: eventList, parameters: [])
            return pattern
            
        } catch let error {
            throw error
        }
    }
}
