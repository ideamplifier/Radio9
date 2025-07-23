//
//  Radio9App.swift
//  Radio9
//
//  Created by EUIHYUNG JUNG on 7/22/25.
//

import SwiftUI
import AVFoundation

@main
struct Radio9App: App {
    init() {
        // Configure URLSession for ultra-fast streaming
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0  // Aggressive timeout
        config.timeoutIntervalForResource = 30.0
        config.waitsForConnectivity = false  // Don't wait, fail fast
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        
        // Optimize for streaming
        // HTTP/2 and HTTP/3 are enabled by default in modern URLSession
        config.httpMaximumConnectionsPerHost = 20  // More connections
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil  // No caching for live streams
        
        // Network service type for better QoS
        config.networkServiceType = .avStreaming
        
        // Apply as default
        URLSessionConfiguration.default.timeoutIntervalForRequest = 5.0
        URLSessionConfiguration.default.httpMaximumConnectionsPerHost = 20
        
        // Configure audio session for app launch
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                           mode: .default,
                                                           options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Set preferred buffer duration - more realistic value
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.02)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
