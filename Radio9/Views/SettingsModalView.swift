import SwiftUI

struct SettingsModalView: View {
    @ObservedObject var viewModel: RadioViewModel
    @Environment(\.dismiss) var dismiss
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(LocalizationHelper.getLocalizedString(for: "settings"))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .padding(.top, 30)
                .padding(.bottom, 12)
            
            // Suggest Radio Channel button
            Button(action: {
                // Open email for channel suggestions
                let subject = LocalizationHelper.getLocalizedString(for: "suggest_radio_channel")
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "mailto:hosonoradio@gmail.com?subject=\(subject)") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                        .frame(width: 28)
                    
                    Text(LocalizationHelper.getLocalizedString(for: "suggest_radio_channel"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.08))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Haptic Feedback Toggle
            HStack {
                Image(systemName: "hand.tap")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                    .frame(width: 28)
                
                Text(LocalizationHelper.getLocalizedString(for: "haptic_feedback"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $hapticFeedbackEnabled)
                    .labelsHidden()
                    .tint(.orange)
                    .onChange(of: hapticFeedbackEnabled) { value in
                        if value {
                            HapticManager.shared.impact(style: .light)
                        }
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.08))
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Legal Notice
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizationHelper.getLocalizedString(for: "legal_notice"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(LocalizationHelper.getLocalizedString(for: "disclaimer_text"))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.08))
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // App info - 인스타그램 연결
            Button(action: {
                // 인스타그램 앱으로 먼저 시도
                if let url = URL(string: "instagram://user?username=HosonoRadio"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else if let webURL = URL(string: "https://www.instagram.com/HosonoRadio/") {
                    // 인스타그램 앱이 없으면 웹으로
                    UIApplication.shared.open(webURL)
                }
            }) {
                VStack(spacing: 8) {
                    Text("HOSONO Radio")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(LocalizationHelper.getLocalizedString(for: "version")) 1.1.0")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 30)
        }
        .presentationDetents([.height(480)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(30)
    }
}