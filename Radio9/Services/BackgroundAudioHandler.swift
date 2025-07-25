//
//  BackgroundAudioHandler.swift
//  Radio9
//
//  Created by Claude on 7/25/25.
//

import Foundation
import AVFoundation
import UIKit

class BackgroundAudioHandler {
    static let shared = BackgroundAudioHandler()
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleEnterBackground() {
        print("✅ Background: Audio session active")
        
        // Start background task to keep app alive
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // Ensure audio session remains active with proper category
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Make sure we have the right category
            if audioSession.category != .playback {
                try audioSession.setCategory(.playback, mode: .default)
            }
            try audioSession.setActive(true)
            print("✅ Background: Audio session category: \(audioSession.category.rawValue)")
        } catch {
            print("❌ Background: Failed to keep audio session active: \(error)")
        }
    }
    
    @objc private func handleEnterForeground() {
        endBackgroundTask()
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        endBackgroundTask()
    }
}