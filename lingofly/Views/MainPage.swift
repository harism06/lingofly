/*
 Pilot (You): Los Alamitos Ground, Cessna N739KD, requesting taxi clearance to Runway 4R.
 ATC Ground: Cessna N739KD, taxi to Runway 4R, via bravo, cross Runway 4L, hold short of Runway 4R.
 Pilot (You): Taxi to Runway 4R via bravo, cross Runway 4L, hold short of Runway 4R, Cessna 9KD.
 ATC Ground: Cessna 9KD, contact Tower 118.4.
 Pilot (You): Over to Tower, Cessna 9KD.
 Pilot (You): Los Alamitos Tower, Cessna N739KD holding short Runway 4R, ready for departure.
 ATC Tower: Cessna 9KD, winds 224 at 3, Runway 4R cleared for takeoff. Fly runway heading after departure.
 Pilot (You): Cleared for takeoff Runway 4R, fly runway heading, Cessna 9KD.
 ATC Tower: Cessna 9KD, climb and maintain 2,500 feet.
 Pilot (You): Climb and maintain 2,500, Cessna 9KD.
 ATC Tower: Cessna 9KD, monitor Unicom 122.95. Bye bye.
 Pilot (You): Wilco, switching to Unicom at 122.95, Cessna 9KD.
 
 Plane Coordinates:
 1) x:0.15 y:0.775 deg: 11
 2) x:0.81 y:0.96 deg: 11
 3) x: 0.765 y: 0.84 deg: 11 -> 242
 4) x:0.43 y:0.1 deg: 242
*/
import SwiftUI
import AVFoundation

// MARK: - Data Models

struct PlaneAction {
    let target: CGPoint?   // where to move (x%, y%)
    let heading: Double?   // optional rotation
    let delay: Double      // delay before this action starts
}

struct DialogueLine {
    let speaker: String
    let text: String
    let audioName: String
    let actions: [PlaneAction]   // sequence of plane moves/rotations
}

// MARK: - Main Page

struct MainPage: View {
    @State private var planeXPercent: CGFloat = 0.15
    @State private var planeYPercent: CGFloat = 0.775
    @State private var planeRotation: Double = 11 // starting rotation
    @State private var currentIndex: Int = 0
    @State private var audioPlayer: AVAudioPlayer?

    // Example dialogue script
    private let dialogue: [DialogueLine] = [
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Los Alamitos Ground, Cessna N739KD, requesting taxi clearance to Runway 4R.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "ATC Ground",
            text: "Cessna N739KD, taxi to Runway 4R, via bravo, cross Runway 4L, hold short of Runway 4R.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Taxi to Runway 4R via bravo, cross Runway 4L, hold short of Runway 4R, Cessna 9KD.",
            audioName: "atc1",
            actions: [
                PlaneAction(target: CGPoint(x: 0.81, y: 0.96), heading: nil, delay: 0),   // move first
                PlaneAction(target: nil, heading: 242, delay: 0.5),                      // then rotate
                PlaneAction(target: CGPoint(x: 0.765, y: 0.84), heading: nil, delay: 1)  // then move again
            ]
        ),
        
        DialogueLine(
            speaker: "ATC Ground",
            text: "Cessna 9KD, contact Tower 118.4.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Over to Tower, Cessna 9KD.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Los Alamitos Tower, Cessna N739KD holding short Runway 4R, ready for departure.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "ATC Tower",
            text: "Cessna 9KD, winds 224 at 3, Runway 4R cleared for takeoff. Fly runway heading after departure.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Cleared for takeoff Runway 4R, fly runway heading, Cessna 9KD.",
            audioName: "atc1",
            actions: [
                PlaneAction(target: CGPoint(x: 0.43, y: 0.1), heading: nil, delay: 0)
            ]
        ),
        DialogueLine(
            speaker: "ATC Tower",
            text: "Cessna 9KD, climb and maintain 2,500 feet.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Climb and maintain 2,500, Cessna 9KD.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "ATC Tower",
            text: "Cessna 9KD, monitor Unicom 122.95. Bye bye.",
            audioName: "atc1",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Wilco, switching to Unicom at 122.95, Cessna 9KD.",
            audioName: "atc1",
            actions: []
        ),
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
            
            let actions = dialogue[currentIndex].actions
            for (i, action) in actions.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + action.delay + Double(i)) {
                    if let heading = action.heading {
                        planeRotation = heading
                    }
                    if let target = action.target {
                        planeXPercent = target.x
                        planeYPercent = target.y
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
