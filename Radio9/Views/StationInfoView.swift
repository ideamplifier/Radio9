import SwiftUI

struct StationInfoView: View {
    let station: RadioStation?
    let frequency: Double
    let isPlaying: Bool
    let isLoading: Bool
    @ObservedObject var viewModel: RadioViewModel
    @State private var glowAnimation = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Station name or Country selection
            VStack(alignment: .leading, spacing: 2) {
                if viewModel.isCountrySelectionMode {
                    // Country name
                    Text(viewModel.selectedCountry.name)
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                        .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: glowAnimation ? 8 : 5)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Select Country text
                    Text("SELECT COUNTRY")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.7))
                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                        .frame(height: 12)  // 고정 높이
                } else {
                    // Station name
                    Text(station?.name ?? "- - - -")
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                        .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: glowAnimation ? 8 : 5)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 하단 텍스트 영역 - 항상 높이 확보
                    Group {
                        if isLoading {
                            Text("loading...")
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.5))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.3), radius: 1)
                        } else if let subGenre = station?.subGenre {
                            Text(subGenre.uppercased())
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.7))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                        } else {
                            Text(" ")  // 빈 공간 확보
                                .font(.system(size: 10))
                        }
                    }
                    .frame(height: 12)  // 고정 높이
                }
            }
            .frame(maxWidth: 200)  // 최대 너비 제한
            .offset(y: -12)  // 2픽셀 더 위로 (-10 -> -12)
            
            Spacer()
            
            // Digital frequency readout
            HStack(spacing: 8) {
                FrequencyReadout(frequency: frequency)
            }
            .frame(minWidth: 140, alignment: .trailing) // MHz 절대 안잘리게
            .offset(y: 30)  // 10픽셀 위로 (40 -> 30)
            
            // Power indicator (국가 선택 모드에서는 숨김)
            if !viewModel.isCountrySelectionMode {
                PowerIndicator(isPlaying: isPlaying, isLoading: isLoading, hasStation: station != nil)
                    .offset(x: 1, y: 31)  // 1픽셀 우측, 1픽셀 아래로
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 65)  // 30픽셀 더 위로 (35 -> 65)
        .onAppear {
            glowAnimation = true
        }
    }
}

struct FrequencyReadout: View {
    let frequency: Double
    
    var body: some View {
        HStack(spacing: 2) {
            // 주파수 숫자
            Text(String(format: "%05.1f", frequency))
                .font(.system(size: 22, weight: .light, design: .monospaced))
                .foregroundColor(Color(red: 1.0, green: 0.95, blue: 0.8))
                .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4), radius: 6)
            
            // MHz 텍스트 - 원래 크기
            Text("MHz")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.6))
                .offset(y: 6)
        }
        .fixedSize() // 절대 줄바꿈 방지
        .id("frequency") // 고정 ID로 재렌더링 방지
        .animation(.none, value: frequency) // 애니메이션 제거
    }
}

struct PowerIndicator: View {
    let isPlaying: Bool
    let isLoading: Bool
    let hasStation: Bool
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(hasStation ? (isLoading ? Color(red: 1.0, green: 0.9, blue: 0.7) : (isPlaying ? Color(red: 0.2, green: 0.8, blue: 0.2) : Color(red: 0.3, green: 0.3, blue: 0.3))) : Color(red: 0.3, green: 0.3, blue: 0.3))
                .frame(width: 10, height: 10)
                .opacity(isLoading && hasStation ? (pulseAnimation ? 0.3 : 0.7) : 1.0)
            
            if hasStation && (isPlaying || isLoading) {
                Circle()
                    .fill(isLoading ? Color(red: 1.0, green: 0.95, blue: 0.8) : Color(red: 0.4, green: 1.0, blue: 0.4))
                    .frame(width: 5, height: 5)
                    .blur(radius: 1)
                    .opacity(isLoading ? (pulseAnimation ? 0.2 : 0.7) : 1.0)
            }
        }
        .shadow(color: hasStation ? (isLoading ? Color(red: 1.0, green: 0.9, blue: 0.7) : (isPlaying ? Color.green : Color.clear)) : Color.clear, radius: 8)
        .onAppear {
            if isLoading && hasStation {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: isLoading) { newValue in
            if newValue && hasStation {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            } else {
                withAnimation(.default) {
                    pulseAnimation = false
                }
            }
        }
    }
}