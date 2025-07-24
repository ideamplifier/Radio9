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
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateEqualizer()
        }
    }
    
    private func updateEqualizer() {
        // 더 부드러운 이퀄라이저 애니메이션
        withAnimation(.easeInOut(duration: 0.2)) {
            for col in 0..<columns {
                let currentHeight = equalizerLevels.enumerated().filter { $0.element[col] > 0.5 }.count
                let targetHeight = Int.random(in: 0...rows)
                
                // 부드러운 전환을 위해 현재 높이와 목표 높이 사이의 차이를 제한
                let smoothedHeight = currentHeight > 0 ? 
                    max(0, min(rows, currentHeight + Int.random(in: -2...2))) : 
                    targetHeight
                
                for row in 0..<rows {
                    equalizerLevels[row][col] = row >= (rows - smoothedHeight) ? 1.0 : 0.0
                }
            }
        }
    }
    
    @ViewBuilder
    private func speakerDot(row: Int, column: Int) -> some View {
        Circle()
            .fill(viewModel.isPlaying && !viewModel.isLoading && equalizerLevels[row][column] > 0.5 ? 
                  Color(red: 0.2, green: 0.17, blue: 0.0).opacity(0.92) : 
                  Color.black.opacity(0.25))
            .frame(width: 4, height: 4)
            .animation(.easeInOut(duration: 0.3), value: equalizerLevels[row][column])
    }
}