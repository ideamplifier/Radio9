import SwiftUI

struct SpeakerGrillView: View {
    let rows = 6
    let columns = 30
    @ObservedObject var viewModel: RadioViewModel
    @State private var currentTime = Date()
    @State private var equalizerLevels: [[Double]] = Array(repeating: Array(repeating: 0.0, count: 30), count: 6)
    @State private var timer: Timer?
    
    // 5x3 숫자 폰트 정의
    private let digitPatterns: [String: [[Bool]]] = [
        "0": [[true, true, true], [true, false, true], [true, false, true], [true, false, true], [true, true, true]],
        "1": [[false, true, false], [true, true, false], [false, true, false], [false, true, false], [true, true, true]],
        "2": [[true, true, true], [false, false, true], [true, true, true], [true, false, false], [true, true, true]],
        "3": [[true, true, true], [false, false, true], [true, true, true], [false, false, true], [true, true, true]],
        "4": [[true, false, true], [true, false, true], [true, true, true], [false, false, true], [false, false, true]],
        "5": [[true, true, true], [true, false, false], [true, true, true], [false, false, true], [true, true, true]],
        "6": [[true, true, true], [true, false, false], [true, true, true], [true, false, true], [true, true, true]],
        "7": [[true, true, true], [false, false, true], [false, false, true], [false, false, true], [false, false, true]],
        "8": [[true, true, true], [true, false, true], [true, true, true], [true, false, true], [true, true, true]],
        "9": [[true, true, true], [true, false, true], [true, true, true], [false, false, true], [true, true, true]],
        ":": [[false], [true], [false], [true], [false]]
    ]
    
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
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: viewModel.isPlaying ? 0.1 : 1.0, repeats: true) { _ in
            if viewModel.isPlaying {
                updateEqualizer()
            } else {
                currentTime = Date()
            }
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
        if viewModel.isPlaying {
            // 이퀄라이저 모드
            Circle()
                .fill(equalizerLevels[row][column] > 0.5 ? 
                      Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.8) : 
                      Color.black.opacity(0.25))
                .frame(width: 4, height: 4)
                .animation(.easeInOut(duration: 0.1), value: equalizerLevels[row][column])
        } else {
            // 시계 모드
            Circle()
                .fill(shouldShowDot(row: row, column: column) ? 
                      Color.black.opacity(0.7) : 
                      Color.black.opacity(0.25))
                .frame(width: 4, height: 4)
        }
    }
    
    private func shouldShowDot(row: Int, column: Int) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: currentTime)
        
        // 시간 문자열을 개별 문자로 분리
        let digits = Array(timeString)
        
        // 각 숫자의 시작 위치 (중앙 정렬)
        let positions = [3, 7, 13, 17, 23, 27] // HH:MM 위치
        
        for (index, digit) in digits.enumerated() {
            let digitStr = String(digit)
            guard let pattern = digitPatterns[digitStr] else { continue }
            
            let startCol = positions[index]
            let width = digitStr == ":" ? 1 : 3
            
            // 각 숫자 패턴 확인
            if column >= startCol && column < startCol + width && row < pattern.count {
                let patternRow = row
                let patternCol = column - startCol
                if patternRow < pattern.count && patternCol < pattern[patternRow].count {
                    if pattern[patternRow][patternCol] {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}