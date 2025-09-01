import SwiftUI

struct MainPage: View {
    @State private var planePosition = CGPoint(x: 200, y: 300)
    
    var body: some View {
        VStack(spacing: 0) {
            // Map area
            ZStack {
                Image("airport")
                    .resizable()
                    .scaledToFit() // changed to keep proportions
                    .ignoresSafeArea()
                
                // Airplane sprite with drag
                Image("plane")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .position(planePosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                planePosition = value.location
                            }
                    )
            }
            
            // Bottom ATC bar
            VStack {
                Text("ATC: Cleared for takeoff runway 27")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Button {
                    print("Play ATC audio")
                } label: {
                    Label("Play", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(.thinMaterial)
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
