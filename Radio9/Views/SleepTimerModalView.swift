import SwiftUI

struct SleepTimerModalView: View {
    @ObservedObject var viewModel: RadioViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedMinutes: Int? = nil
    
    let timerOptions = [15, 30, 45, 60]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(LocalizationHelper.getLocalizedString(for: "sleep_timer"))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .padding(.top, 30)
                .padding(.bottom, 20)
            
            VStack(spacing: 12) {
                // Timer options
                ForEach(timerOptions, id: \.self) { minutes in
                    Button(action: {
                        if viewModel.isSleepTimerActive && viewModel.sleepTimerMinutes == minutes {
                            // Cancel timer if same time is selected
                            viewModel.cancelSleepTimer()
                            HapticManager.shared.impact(style: .light)
                            dismiss()
                        } else {
                            // Set new timer
                            selectedMinutes = minutes
                            viewModel.setSleepTimer(minutes: minutes)
                            HapticManager.shared.impact(style: .light)
                            
                            // Dismiss after short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            Text(String(format: LocalizationHelper.getLocalizedString(for: "minutes_format"), minutes))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if viewModel.isSleepTimerActive && 
                               viewModel.sleepTimerMinutes == minutes {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 20, height: 20)
                                    
                                    Text("–")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .offset(y: -1)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    viewModel.isSleepTimerActive && 
                                    viewModel.sleepTimerMinutes == minutes ?
                                    Color.orange.opacity(0.1) : 
                                    Color.gray.opacity(0.08)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(30)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}