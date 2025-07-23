//
//  Radio9App.swift
//  Radio9
//
//  Created by EUIHYUNG JUNG on 7/22/25.
//

import SwiftUI
import SwiftData

@main
struct Radio9App: App {
    init() {
        // Configure URLSession for better streaming support
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        
        // This helps with streaming protocols
        config.httpShouldUsePipelining = true
        config.httpMaximumConnectionsPerHost = 10
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
