import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.05, blue: 0.05),  // Deep black
                Color(red: 0.15, green: 0.15, blue: 0.15)   // Slightly lighter black
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct ContentView: View {
    // Game state
    @State private var gameState: GameState = .ready
    @State private var startTime: Date?
    @State private var reactionTime: Double?
    @State private var showTapNow = false
    @State private var tapNowOpacity: Double = 0.0
    @State private var startButtonOpacity: Double = 0.0
    
    // Signal light states
    @State private var light1On = false
    @State private var light2On = false
    @State private var light3On = false
    @State private var light4On = false
    @State private var light5On = false
    
    // Animation states
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var taglineOpacity: Double = 0.0
    
    // Constants
    private let minDelay: TimeInterval = 2.0
    private let maxDelay: TimeInterval = 5.0
    private let lightSize: CGFloat = 50
    private let lightSpacing: CGFloat = 15
    
    // Font styles
    private let titleFont = Font.system(size: 40, weight: .bold, design: .monospaced)
    private let mainFont = Font.system(size: 30, weight: .bold, design: .monospaced)
    private let taglineFont = Font.system(size: 20, weight: .medium, design: .monospaced)
    private let resultFont = Font.system(size: 24, weight: .medium, design: .monospaced)
    
    enum GameState {
        case ready
        case signals
        case waiting
        case tapNow
        case result
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with gradient
                GradientBackground()
                
                VStack(spacing: 20) {
                    // Title
                    Text("ReactNow")
                        .font(titleFont)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    // Tagline
                    Text("Lights Out and Away We Go!")
                        .font(taglineFont)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .opacity(taglineOpacity)
                        .animation(.easeIn(duration: 1.0), value: taglineOpacity)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Game content
                    Group {
                        switch gameState {
                        case .ready:
                            Button(action: startGame) {
                                Text("Start Now")
                                    .font(mainFont)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.red)
                                            .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 0)
                                    )
                            }
                            .padding(.horizontal, 40)
                            .opacity(startButtonOpacity)
                            .animation(.easeIn(duration: 1.0), value: startButtonOpacity)
                            
                        case .signals:
                            VStack {
                                Spacer()
                                HStack(spacing: lightSpacing) {
                                    SignalLight(isOn: light1On)
                                    SignalLight(isOn: light2On)
                                    SignalLight(isOn: light3On)
                                    SignalLight(isOn: light4On)
                                    SignalLight(isOn: light5On)
                                }
                                .frame(maxWidth: .infinity)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                        case .waiting:
                            Text("Get Ready...")
                                .font(mainFont)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            
                        case .tapNow:
                            VStack(spacing: 10) {
                                Text("Tap Now!")
                                    .font(mainFont)
                                    .foregroundColor(.red)
                                    .scaleEffect(showTapNow ? 1.2 : 1.0)
                                    .opacity(tapNowOpacity)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showTapNow)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                
                                Text("🏁")
                                    .font(.system(size: 40))
                                    .opacity(tapNowOpacity)
                                    .animation(.easeIn(duration: 0.5), value: tapNowOpacity)
                            }
                            
                        case .result:
                            if let reactionTime = reactionTime {
                                VStack(spacing: 20) {
                                    Text("Your reaction time:")
                                        .font(resultFont)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                    
                                    Text("\(Int(reactionTime)) ms")
                                        .font(mainFont)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                    
                    // Play Again button
                    if gameState == .result {
                        Button(action: resetGame) {
                            Text("Play Again")
                                .font(resultFont)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.red)
                                        .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 0)
                                )
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            taglineOpacity = 1.0
            withAnimation(.easeIn(duration: 1.0)) {
                startButtonOpacity = 1.0
            }
        }
    }
    
    private func startGame() {
        gameState = .signals
        startSignalSequence()
    }
    
    private func startSignalSequence() {
        // First light
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                light1On = true
            }
            
            // Second light
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    light2On = true
                }
                
                // Third light
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        light3On = true
                    }
                    
                    // Fourth light
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            light4On = true
                        }
                        
                        // Fifth light
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                light5On = true
                            }
                            
                            // Turn off all lights simultaneously and show "Tap Now!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    light1On = false
                                    light2On = false
                                    light3On = false
                                    light4On = false
                                    light5On = false
                                }
                                
                                // Start the fade-in animation for "Tap Now!"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    startTime = Date()
                                    gameState = .tapNow
                                    showTapNow = true
                                    withAnimation(.easeIn(duration: 0.5)) {
                                        tapNowOpacity = 1.0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func handleTap() {
        switch gameState {
        case .ready, .waiting, .signals:
            // Ignore taps during ready/waiting/signals state
            break
            
        case .tapNow:
            if let startTime = startTime {
                reactionTime = Date().timeIntervalSince(startTime) * 1000
                gameState = .result
            }
            
        case .result:
            // Ignore taps during result state
            break
        }
    }
    
    private func resetGame() {
        gameState = .ready
        reactionTime = nil
        showTapNow = false
        tapNowOpacity = 0.0
        startButtonOpacity = 1.0
        light1On = false
        light2On = false
        light3On = false
        light4On = false
        light5On = false
    }
}

struct SignalLight: View {
    let isOn: Bool
    private let size: CGFloat = 50
    
    var body: some View {
        Circle()
            .fill(isOn ? Color.red : Color.white.opacity(0.3))
            .frame(width: size, height: size)
            .shadow(color: isOn ? .red : .clear, radius: 10, x: 0, y: 0)
            .animation(.easeInOut(duration: 0.5), value: isOn)
    }
}

#Preview {
    ContentView()
} 