import SwiftUI

struct SpeakerGrillView: View {
    let rows = 6
    let columns = 28
    @Binding var isPowerOn: Bool
    @State private var animationRow = -1
    
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
        .onChange(of: isPowerOn) { newValue in
            if newValue {
                // Animate rows filling up (0.3초) - easeOut으로 빠르게 시작
                animationRow = 0
                withAnimation(.easeOut(duration: 0.08)) {
                    animationRow = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        animationRow = 2
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.easeOut(duration: 0.12)) {
                        animationRow = 3
                    }
                }
                
                // Hold for 0.7초 (0.3초 올라감 + 0.7초 머뭄 = 1.0초에 시작)
                
                // Animate rows clearing (1.2초) - easeIn으로 천천히 시작
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        animationRow = 2
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        animationRow = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation(.easeInOut(duration: 0.8)) {  // 0.7 -> 0.8초로 변경
                        animationRow = 0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {  // 2.4 -> 2.5초로 조정
                    withAnimation(.easeOut(duration: 0.1)) {
                        animationRow = -1
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func speakerDot(row: Int, column: Int) -> some View {
        Circle()
            .fill(row >= (rows - animationRow) && animationRow > 0 ? Color.orange : Color.black.opacity(0.25))
            .frame(width: 4, height: 4)
            .animation(.easeInOut(duration: 0.1), value: animationRow)
    }
}