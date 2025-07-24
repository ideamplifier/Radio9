import SwiftUI

struct SpeakerGrillView: View {
    let rows = 6
    let columns = 30
    @ObservedObject var viewModel: RadioViewModel
    @State private var equalizerLevels: [[Double]] = Array(repeating: Array(repeating: 0.0, count: 30), count: 6)
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<columns, id: \.self) { column in
                        speakerDot(row: row, column: column)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.97))
                .shadow(color: .black.opacity(0.02), radius: 1, x: 0, y: 1)
        )
        .onAppear {
            if viewModel.isPlaying && !viewModel.isLoading {
                startTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: viewModel.isPlaying) { isPlaying in
            if isPlaying && !viewModel.isLoading {
                startTimer()
            } else {
                timer?.invalidate()
                // Reset equalizer levels smoothly
                withAnimation(.easeOut(duration: 0.3)) {
                    equalizerLevels = Array(repeating: Array(repeating: 0.0, count: 30), count: 6)
                }
            }
        }
        .onChange(of: viewModel.isLoading) { isLoading in
            if isLoading {
                timer?.invalidate()
                withAnimation(.easeOut(duration: 0.3)) {
                    equalizerLevels = Array(repeating: Array(repeating: 0.0, count: 30), count: 6)
                }
            } else if viewModel.isPlaying {
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateEqualizer()
        }
    }
    
    private func updateEqualizer() {
        // 웨이브 형태의 이퀄라이저
        for col in 0..<columns {
            // 시간 기반 웨이브 패턴
            let time = Date().timeIntervalSince1970
            let wave = sin(time * 2.0 + Double(col) * 0.3) // 각 열마다 위상 차이
            let baseHeight = (wave + 1.0) * 2.5 + 1.0 // 1~6 범위
            
            // 랜덤 변동 추가
            let randomVariation = Double.random(in: -0.5...0.5)
            let targetHeight = baseHeight + randomVariation
            
            // 현재 높이와 보간
            var currentHeight = 0.0
            for row in (0..<rows).reversed() {
                if equalizerLevels[row][col] > 0.01 {
                    currentHeight = Double(rows - row)
                    break
                }
            }
            
            let smoothedHeight = currentHeight * 0.85 + targetHeight * 0.15
            
            // 모든 셀 업데이트
            for row in 0..<rows {
                let distanceFromBottom = Double(rows - 1 - row)
                if distanceFromBottom < smoothedHeight {
                    // 중앙이 가장 밝고 위아래로 갈수록 어두워지는 효과
                    let centerDistance = abs(distanceFromBottom - smoothedHeight / 2.0)
                    let intensity = 1.0 - (centerDistance / (smoothedHeight / 2.0)) * 0.5
                    equalizerLevels[row][col] = max(0.2, min(1.0, intensity))
                } else {
                    equalizerLevels[row][col] = 0.0
                }
            }
        }
    }
    
    @ViewBuilder
    private func speakerDot(row: Int, column: Int) -> some View {
        Circle()
            .fill(viewModel.isPlaying && !viewModel.isLoading && equalizerLevels[row][column] > 0.01 ? 
                  Color(red: 0.2, green: 0.17, blue: 0.0).opacity(equalizerLevels[row][column] * 0.85) : 
                  Color.black.opacity(0.25))
            .frame(width: 4, height: 4)
            .animation(.easeInOut(duration: 0.15), value: equalizerLevels[row][column])
    }
}