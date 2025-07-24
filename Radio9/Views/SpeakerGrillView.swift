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
            if viewModel.isPlaying {
                startTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: viewModel.isPlaying) { isPlaying in
            if isPlaying {
                startTimer()
            } else {
                timer?.invalidate()
                // Reset equalizer levels
                equalizerLevels = Array(repeating: Array(repeating: 0.0, count: 30), count: 6)
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
        // 이퀄라이저 애니메이션 업데이트
        for col in 0..<columns {
            let targetHeight = Int.random(in: 0...rows)
            for row in 0..<rows {
                equalizerLevels[row][col] = row >= (rows - targetHeight) ? 1.0 : 0.0
            }
        }
    }
    
    @ViewBuilder
    private func speakerDot(row: Int, column: Int) -> some View {
        Circle()
            .fill(viewModel.isPlaying && equalizerLevels[row][column] > 0.5 ? 
                  Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.8) : 
                  Color.black.opacity(0.25))
            .frame(width: 4, height: 4)
            .animation(.easeInOut(duration: 0.1), value: equalizerLevels[row][column])
    }
}