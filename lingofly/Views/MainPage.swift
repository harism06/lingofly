import SwiftUI

struct MainPage: View {
    // Store percentages instead of absolute points
    @State private var planeXPercent: CGFloat = 0.15
    @State private var planeYPercent: CGFloat = 0.775
    
    var body: some View {
        VStack(spacing: 0) {
            // Map area
            GeometryReader { geo in
                ZStack {
                    // Image scales to fit
                    Image("airport")
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            GeometryReader { imgGeo in
                                let imgSize = imgGeo.size
                                
                                // Compute actual position inside the image
                                let planePosition = CGPoint(
                                    x: imgSize.width * planeXPercent,
                                    y: imgSize.height * planeYPercent
                                )
                                
                                Image("plane")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .rotationEffect(.degrees(11))
                                    .position(planePosition)
                            }
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .ignoresSafeArea()
            
            // Bottom ATC bar
            VStack {
                HStack(spacing: 10) {
                    Button {
                        print("Play ATC audio")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Text("ATC: Cleared for takeoff runway 27")
                        .font(.title3)
                        .lineLimit(1)
                    
                    Image(systemName: "arrow.right")
                        .font(.title3)
                }
                .padding(.bottom, 5)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(.thinMaterial)
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
