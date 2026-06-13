import SwiftUI

struct WaveformView: View {
    let soundLevels: [Float]

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(0..<soundLevels.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [PinguDesign.lightBlue, PinguDesign.blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: 6,
                        height: CGFloat(soundLevels[index] * 110)
                    )
                    .animation(.spring(response: 0.16, dampingFraction: 0.62), value: soundLevels[index])
            }
        }
        .frame(height: 120)
    }
}

#Preview {
    WaveformView(soundLevels: Array(repeating: 0.2, count: 25))
}
