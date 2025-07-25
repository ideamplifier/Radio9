import SwiftUI

struct EqualizerView: View {
    @ObservedObject var audioAnalyzer: AudioAnalyzer
    @Binding var isPlaying: Bool
    @State private var animatedBands: [CGFloat] = Array(repeating: 0.0, count: 28)
    @State private var columnHeights: [[CGFloat]] = Array(repeating: Array(repeating: 0.0, count: 6), count: 28)
    
    let columns = 28
    let rows = 6
    
    // 각 열이 담당하는 주파수 대역 매핑
    private let columnToBandMapping: [Int] = {
        // 28개 열을 6개 주파수 대역에 분배
        // 저음역대는 더 많은 열, 고음역대는 적은 열
        var mapping: [Int] = []
        mapping.append(contentsOf: Array(repeating: 0, count: 6))  // Sub-bass (6 columns)
        mapping.append(contentsOf: Array(repeating: 1, count: 6))  // Bass (6 columns)
        mapping.append(contentsOf: Array(repeating: 2, count: 5))  // Low-mid (5 columns)
        mapping.append(contentsOf: Array(repeating: 3, count: 5))  // Mid (5 columns)
        mapping.append(contentsOf: Array(repeating: 4, count: 3))  // High-mid (3 columns)
        mapping.append(contentsOf: Array(repeating: 5, count: 3))  // High (3 columns)
        return mapping
    }()
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<columns, id: \.self) { column in
                        EqualizerDot(
                            isActive: shouldActivateDot(row: row, column: column),
                            intensity: getDotIntensity(row: row, column: column)
                        )
                    }
                }
            }
        }
        .onReceive(audioAnalyzer.$frequencyBands) { bands in
            updateVisualization(bands: bands)
        }
        .onReceive(audioAnalyzer.$beatDetected) { beat in
            if beat {
                addBeatEffect()
            }
        }
    }
    
    private func updateVisualization(bands: [Float]) {
        guard isPlaying else {
            // Clear visualization when not playing
            withAnimation(.easeOut(duration: 0.5)) {
                for i in 0..<columns {
                    columnHeights[i] = Array(repeating: 0.0, count: rows)
                }
            }
            return
        }
        
        // Update each column based on frequency bands
        for column in 0..<columns {
            let bandIndex = columnToBandMapping[column]
            let bandLevel = CGFloat(bands[bandIndex])
            
            // Add variation between columns in same band
            let variation = CGFloat.random(in: -0.1...0.1)
            let adjustedLevel = max(0, min(1, bandLevel + variation))
            
            // Apply content type specific behavior
            let maxRows = audioAnalyzer.contentType == .speech ? 3 : 6
            let targetHeight = adjustedLevel * CGFloat(maxRows)
            
            // Smooth animation
            withAnimation(.easeInOut(duration: audioAnalyzer.contentType == .speech ? 0.3 : 0.1)) {
                updateColumnHeight(column: column, targetHeight: targetHeight)
            }
        }
    }
    
    private func updateColumnHeight(column: Int, targetHeight: CGFloat) {
        for row in 0..<rows {
            let rowFromBottom = rows - 1 - row
            columnHeights[column][row] = rowFromBottom < Int(targetHeight) ? 1.0 : 0.0
        }
    }
    
    private func shouldActivateDot(row: Int, column: Int) -> Bool {
        let rowFromBottom = rows - 1 - row
        return columnHeights[column][row] > 0.5
    }
    
    private func getDotIntensity(row: Int, column: Int) -> CGFloat {
        return columnHeights[column][row]
    }
    
    private func addBeatEffect() {
        // Add pulse effect on beat detection
        guard audioAnalyzer.contentType == .music else { return }
        
        withAnimation(.easeOut(duration: 0.1)) {
            // Boost all active columns briefly
            for column in 0..<columns {
                for row in 0..<rows {
                    if columnHeights[column][row] > 0 {
                        columnHeights[column][row] = min(1.0, columnHeights[column][row] * 1.2)
                    }
                }
            }
        }
    }
}

struct EqualizerDot: View {
    let isActive: Bool
    let intensity: CGFloat
    
    var body: some View {
        Circle()
            .fill(isActive ? 
                Color.orange.opacity(0.6 + intensity * 0.4) : 
                Color.clear)  // 투명하게 변경 - 배경 점이 보이도록
            .frame(width: 4, height: 4)
            .scaleEffect(isActive ? 1.0 + intensity * 0.2 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isActive)
            .animation(.easeInOut(duration: 0.1), value: intensity)
    }
}