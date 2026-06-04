import SwiftUI

struct WaveformView: View {

    let heights: [CGFloat] = [
        48, 66, 56, 86, 48, 70, 58, 90, 52
    ]

    var body: some View {

        HStack(alignment: .center, spacing: 8) {

            ForEach(heights.indices, id: \.self) { index in

                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [PinguDesign.lightBlue, PinguDesign.blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: 9,
                        height: heights[index]
                    )
            }
        }
    }
}

#Preview {
    WaveformView()
}
