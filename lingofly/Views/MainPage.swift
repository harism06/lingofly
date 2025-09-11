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
    @State private var showNextButton: Bool = false // Track if next button should be visible
    @State private var audioDelegate = AudioPlayerDelegate() // Custom delegate to handle audio completion

    // Example dialogue script
    private let dialogue: [DialogueLine] = [
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Los Alamitos Ground, Cessna N739KD, requesting taxi clearance to Runway 4R.",
            audioName: "Pilot1",
            actions: []
        ),
        DialogueLine(
            speaker: "ATC Ground",
            text: "Cessna N739KD, taxi to Runway 4R, via Bravo, cross Runway 4L, hold short of Runway 4R.",
            audioName: "ATC1",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Taxi to Runway 4R via Bravo, cross Runway 4L, hold short of Runway 4R, Cessna 9KD.",
            audioName: "Pilot2",
            actions: [
                PlaneAction(target: CGPoint(x: 0.81, y: 0.96), heading: nil, delay: 0),   // move first
                PlaneAction(target: nil, heading: 242, delay: 0.5),                      // then rotate
                PlaneAction(target: CGPoint(x: 0.765, y: 0.84), heading: nil, delay: 1)  // then move again
            ]
        ),
        
        DialogueLine(
            speaker: "ATC Ground",
            text: "Cessna 9KD, contact Tower 118.4.",
            audioName: "ATC2",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Over to Tower, Cessna 9KD.",
            audioName: "Pilot3",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Los Alamitos Tower, Cessna N739KD holding short Runway 4R, ready for departure.",
            audioName: "Pilot4",
            actions: []
        ),
        DialogueLine(
            speaker: "ATC Tower",
            text: "Cessna 9KD, winds 224 at 3, Runway 4R cleared for takeoff. Fly runway heading after departure.",
            audioName: "ATC3",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Cleared for takeoff Runway 4R, fly runway heading, Cessna 9KD.",
            audioName: "Pilot5",
            actions: [
                PlaneAction(target: CGPoint(x: 0.43, y: 0.1), heading: nil, delay: 0)
            ]
        ),
        DialogueLine(
            speaker: "ATC Tower",
            text: "Cessna 9KD, climb and maintain 2,500 feet.",
            audioName: "ATC4",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Climb and maintain 2,500, Cessna 9KD.",
            audioName: "Pilot6",
            actions: []
        ),
        DialogueLine(
            speaker: "ATC Tower",
            text: "Cessna 9KD, monitor Unicom 122.95. Bye bye.",
            audioName: "ATC5",
            actions: []
        ),
        DialogueLine(
            speaker: "Pilot (You)",
            text: "Wilco, switching to Unicom at 122.95, Cessna 9KD.",
            audioName: "Pilot7",
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
                    
                    Button {
                        playCurrentAudio()
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Text(dialogue[currentIndex].speaker + ": " + dialogue[currentIndex].text)
                        .font(.title3)
                        .lineLimit(1)
                    
                    // Always show the button but make it invisible/disabled when audio is playing
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
                    .opacity(showNextButton ? 1.0 : 0.0)
                    .disabled(!showNextButton)
                    .animation(.easeInOut(duration: 0.3), value: showNextButton)
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
        .onChange(of: currentIndex) { _ in
            // Hide button when switching to a new line
            showNextButton = false
        }
    }
    
    // MARK: Helpers
    
    private func playCurrentAudio() {
        let audioName = dialogue[currentIndex].audioName
        if let url = Bundle.main.url(forResource: audioName, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = audioDelegate
                
                // Set up the completion handler
                audioDelegate.onAudioFinished = {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showNextButton = true
                        }
                    }
                }
                
                audioPlayer?.play()
            } catch {
                print("Error playing \(audioName): \(error)")
                // If there's an error, show the button anyway
                withAnimation(.easeInOut(duration: 0.3)) {
                    showNextButton = true
                }
            }
        } else {
            // If audio file doesn't exist, show the button anyway
            withAnimation(.easeInOut(duration: 0.3)) {
                showNextButton = true
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

// MARK: - Audio Player Delegate

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onAudioFinished: (() -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onAudioFinished?()
    }
}

// MARK: - Preview

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
