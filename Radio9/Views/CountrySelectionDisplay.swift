import SwiftUI

struct CountrySelectionDisplay: View {
    @ObservedObject var viewModel: RadioViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Select Country")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.6).opacity(0.8))
                .padding(.top, 10)
            
            HStack {
                Text(viewModel.selectedCountry.flag)
                    .font(.system(size: 24))
                Text(viewModel.selectedCountry.name)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                    .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: 8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 60)
        .padding(.horizontal, 15)
        .padding(.top, 10)
    }
}