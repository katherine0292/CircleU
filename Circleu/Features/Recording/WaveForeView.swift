import SwiftUI

struct WaveformView: View {
    let soundLevels: [Float]
    let amplitude: Float

    var body: some View {
        ZStack {
            // Glowing pulsing background aura responsive to voice amplitude
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PinguDesign.electricBlue.opacity(0.35 * Double(amplitude)), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 75
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(1.0 + CGFloat(amplitude * 0.4))
                .blur(radius: 12)
                .animation(.spring(response: 0.15, dampingFraction: 0.65), value: amplitude)

            // The waveform bars
            HStack(alignment: .center, spacing: 5) {
                ForEach(0..<soundLevels.count, id: \.self) { index in
                    let level = soundLevels[index]
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    PinguDesign.electricBlue,
                                    PinguDesign.blue,
                                    PinguDesign.sky
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(
                            width: 5,
                            height: max(6, CGFloat(level * 110))
                        )
                        .shadow(
                            color: PinguDesign.blue.opacity(Double(level) * 0.4),
                            radius: 4,
                            x: 0,
                            y: 0
                        )
                        .animation(.spring(response: 0.15, dampingFraction: 0.60), value: level)
                }
            }
        }
        .frame(height: 130)
    }
}

#Preview {
    WaveformView(soundLevels: Array(repeating: 0.2, count: 25), amplitude: 0.5)
}
