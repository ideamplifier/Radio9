import SwiftUI

struct SpeakerGrillView: View {
    let rows = 5
    let columns = 24
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<columns, id: \.self) { column in
                        Circle()
                            .fill(Color.black.opacity(0.25))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .padding(.vertical, 12)
    }
}