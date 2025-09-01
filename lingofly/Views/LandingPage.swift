import SwiftUI

struct LandingPage: View {
    var body: some View {
        VStack(spacing: 20) {
            // your custom header stays
            VStack(spacing: 5) {
                Text("welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("lingofly")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Image("landing")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
            }
            
            NavigationLink("get started") {
                MainPage()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
