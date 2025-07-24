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
        // 더 부드러운 이퀄라이저 애니메이션
        for col in 0..<columns {
            // 현재 높이 계산 (실제 값 기반)
            var currentHeight = 0.0
            for row in (0..<rows).reversed() {
                if equalizerLevels[row][col] > 0.1 {
                    currentHeight = Double(rows - row)
                    break
                }
            }
            
            // 목표 높이 (1~5 범위, 맨 아래부터 시작)
            let targetHeight = Double.random(in: 1...5)
            
            // 부드러운 보간
            let smoothedHeight = currentHeight * 0.7 + targetHeight * 0.3
            
            // 그라데이션 효과를 위한 값 설정 (아래서부터)
            for row in 0..<rows {
                let distanceFromBottom = Double(rows - 1 - row)
                if distanceFromBottom < smoothedHeight {
                    // 높이에 따른 그라데이션 효과
                    let intensity = 1.0 - (smoothedHeight - distanceFromBottom) * 0.2
                    equalizerLevels[row][col] = max(0.3, intensity)
                } else {
                    equalizerLevels[row][col] = 0.0
                }
            }
        }
    }
    
    @ViewBuilder
    private func speakerDot(row: Int, column: Int) -> some View {
        Circle()
            .fill(viewModel.isPlaying && !viewModel.isLoading && equalizerLevels[row][column] > 0.1 ? 
                  Color(red: 0.2, green: 0.17, blue: 0.0).opacity(equalizerLevels[row][column] * 0.92) : 
                  Color.black.opacity(0.25))
            .frame(width: 4, height: 4)
            .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2), value: equalizerLevels[row][column])
    }
}