//
//  Radio9App.swift
//  Radio9
//
//  Created by EUIHYUNG JUNG on 7/22/25.
//

import SwiftUI
import AVFoundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure audio session for background playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            print("✅ AppDelegate: Audio session configured for background playback")
        } catch {
            print("❌ AppDelegate: Failed to configure audio session: \(error)")
        }
        
        // Enable remote control events
        application.beginReceivingRemoteControlEvents()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Ensure audio continues in background
        print("📱 App will resign active - audio should continue")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 App entered background - audio should continue")
    }
}

@main
struct Radio9App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let backgroundHandler = BackgroundAudioHandler.shared
    
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
        // 앱 시작 시에는 오디오 세션을 설정하지 않음
        // RadioViewModel에서 재생 시 설정하도록 함
        
        // But ensure we have the right capabilities
        let audioSession = AVAudioSession.sharedInstance()
        print("🎵 Audio Session Info:")
        print("   Category: \(audioSession.category.rawValue)")
        print("   Mode: \(audioSession.mode.rawValue)")
        print("   Is Other Audio Playing: \(audioSession.isOtherAudioPlaying)")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
