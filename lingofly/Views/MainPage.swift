import SwiftUI
import AVFoundation

/*
 Plane Coordinates:
 1) x:0.15 y:0.775 deg: 11
 2) x:0.81 y:0.96 deg: 11
 3) x: 0.765 y: 0.84 deg: 11 -> 242
 4) x:0.43 y:0.1 deg: 242
 
 Pilot: Los Alamitos Ground, Cessna 172, request taxi to Runway 4R.
 ATC Ground: Cessna 172, taxi to Runway 4R, proceed via main ramp and apron, hold short of the runway.
 Pilot: Taxi to Runway 4R via ramp and apron, hold short, C172.
 Pilot: Los Alamitos Ground, Cessna 172 holding short Runway 4R, run-up complete, ready for departure.
 ATC Ground: Cessna 172, Runway 4R, cleared for takeoff.
 Pilot: Cleared for takeoff, Runway 4R, C172.
 Pilot: Los Alamitos Tower, Cessna 172 airborne, passing 500 feet, runway 20.
 ATC Tower: Cessna 172, radar contact, fly runway heading, climb and maintain 2,500 feet.
 Pilot: Runway heading, climb and maintain 2,500, C172.
 ATC Tower: Cessna 172, no other traffic, you’re clear to switch to advisory frequency when convenient.
 Pilot: Wilco, switching to advisory, C172.
*/

struct DialogueLine {
    let speaker: String
    let text: String
    let audioName: String
    let planeTarget: CGPoint? // x%, y% movement target (0...1)
    let planeHeading: Double? // optional rotation for this line
}

struct MainPage: View {
    @State private var planeXPercent: CGFloat = 0.15
    @State private var planeYPercent: CGFloat = 0.775
    @State private var planeRotation: Double = 11 // starting rotation
    @State private var currentIndex: Int = 0
    @State private var audioPlayer: AVAudioPlayer?

    // Example dialogue script
    private let dialogue: [DialogueLine] = [
        DialogueLine(speaker: "Pilot", text: "Los Alamitos Ground, Cessna 172, request taxi to Runway 4R.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
        DialogueLine(speaker: "ATC Ground", text: "Cessna 172, taxi to Runway 4R, proceed via main ramp and apron, hold short of the runway.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
        DialogueLine(speaker: "Pilot", text: "Taxi to Runway 4R via ramp and apron, hold short, C172.", audioName: "atc1", planeTarget: CGPoint(x: 0.81, y: 0.96), planeHeading: nil),
        DialogueLine(speaker: "Pilot", text: "Los Alamitos Ground, Cessna 172 holding short Runway 4R, run-up complete, ready for departure.", audioName: "atc1", planeTarget: CGPoint(x: 0.765, y: 0.84), planeHeading: 242),
        DialogueLine(speaker: "ATC Ground", text: "Cessna 172, Runway 4R, cleared for takeoff.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
        DialogueLine(speaker: "Pilot", text: "Cleared for takeoff, Runway 4R, C172.", audioName: "atc1", planeTarget: CGPoint(x: 0.43, y: 0.1), planeHeading: nil),
        DialogueLine(speaker: "Pilot", text: "Los Alamitos Tower, Cessna 172 airborne, passing 500 feet, runway 20.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
        DialogueLine(speaker: "ATC Tower", text: "Cessna 172, radar contact, fly runway heading, climb and maintain 2,500 feet.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
        DialogueLine(speaker: "Pilot", text: "Runway heading, climb and maintain 2,500, C172.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
        DialogueLine(speaker: "ATC Tower", text: "Cessna 172, no other traffic, you’re clear to switch to advisory frequency when convenient.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
        DialogueLine(speaker: "Pilot", text: "Wilco, switching to advisory, C172.", audioName: "atc1", planeTarget: nil, planeHeading: nil),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Map & plane
            GeometryReader { geo in
                ZStack {
                    Image("airport")
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            GeometryReader { imgGeo in
                                let imgSize = imgGeo.size
                                let planePosition = CGPoint(
                                    x: imgSize.width * planeXPercent,
                                    y: imgSize.height * planeYPercent
                                )
                                
                                Image("plane")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .rotationEffect(.degrees(planeRotation))
                                    .position(planePosition)
                                    .animation(.easeInOut(duration: 2), value: planeXPercent)
                                    .animation(.easeInOut(duration: 2), value: planeYPercent)
                                    .animation(.easeInOut(duration: 1), value: planeRotation)
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .ignoresSafeArea()
            
            // Bottom ATC bar
            VStack {
                HStack(spacing: 10) {
                    
                    Text(dialogue[currentIndex].speaker + ": " + dialogue[currentIndex].text)
                        .font(.title3)
                        .lineLimit(1)
                    
                    Button {
                        if currentIndex == dialogue.count - 1 {
                                // Last line → quit app
                                exit(0)
                            } else {
                                // Otherwise go to next line
                                goToNextLine()
                            }
                    } label: {
                        Image(systemName: currentIndex == dialogue.count - 1 ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.bottom, 5)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(.thinMaterial)
        }
        .onAppear {
            playCurrentAudio()
        }
    }
    
    // MARK: Helpers
    
    private func playCurrentAudio() {
        let audioName = dialogue[currentIndex].audioName
        if let url = Bundle.main.url(forResource: audioName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing \(audioName): \(error)")
            }
        }
    }
    
    private func goToNextLine() {
        if currentIndex + 1 < dialogue.count {
            currentIndex += 1
            
            playCurrentAudio()
            
            // Rotate first if a new heading is specified
            if let heading = dialogue[currentIndex].planeHeading {
                planeRotation = heading
            }
            
            // Move plane after a small delay so rotation happens first
            if let target = dialogue[currentIndex].planeTarget {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    planeXPercent = target.x
                    planeYPercent = target.y
                }
            }
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
