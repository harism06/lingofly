import SwiftUI

struct AppView: View {
    var body: some View {
        NavigationStack {
            LandingPage()
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
