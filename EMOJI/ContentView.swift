//octexa
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var emojis: [String] = []
    @State private var emojiPositions: [CGPoint] = []
    @State private var emojiSizes: [CGFloat] = []
    @State private var emojiRotations: [Double] = []

    @State private var clickCount: Int = 0
    @State private var totalEmojis: Int = 0
    @State private var totalTimeSpent: Int = 0
    @State private var timer: Timer?
    @State private var clickRate: Int = 0
    @State private var totalClicksInLastMinute: Int = 0
    @State private var averageClickRate: Double = 0
    @State private var highestClickRate: Double = 0

    @State private var showAppInfo: Bool = false
    @State private var level: Int = 1
    @State private var levelProgress: CGFloat = 0.0
    @State private var levelScale: CGFloat = 1.0 // Scale for level effect

    let levelStart: Int = 250
    let levelIncrement: Int = 100
    let higherLevelIncrement: Int = 250

    var averageClickRateColor: Color {
        let maxRate = 10.0
        let ratePercentage = min(averageClickRate / maxRate, 1.0)
        return Color(red: CGFloat(ratePercentage), green: 1 - CGFloat(ratePercentage), blue: 0.5)
    }

    var averageClickRateFontSize: CGFloat {
        let maxFontSize: CGFloat = 40
        let minFontSize: CGFloat = 20
        let normalizedRate = min(averageClickRate / 10.0, 1.0)
        return minFontSize + (maxFontSize - minFontSize) * CGFloat(normalizedRate)
    }

    var levelClickRequirement: Int {
        if level >= 5 {
            return levelStart + (4 * levelIncrement) + ((level - 5) * higherLevelIncrement)
        } else {
            return levelStart + (level - 1) * levelIncrement
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    VStack(spacing: 10) {
                        Text("Button Clicked: \(clickCount) times")
                            .foregroundColor(.white)
                            .font(.title2)

                        Text("Total Emojis Spawned: \(totalEmojis)")
                            .foregroundColor(.white)
                            .font(.title2)

                        Text("Click Rate: \(String(format: "%.1f", averageClickRate)) clicks/sec")
                            .foregroundColor(averageClickRateColor)
                            .font(.system(size: averageClickRateFontSize))
                            .animation(.easeInOut, value: averageClickRate)

                        Text("Highest Click Rate: \(String(format: "%.1f", highestClickRate)) clicks/sec")
                            .foregroundColor(.white)
                            .font(.title2)

                        // Display the level with scale effect
                        HStack {
                            Text("Level: \(level)")
                                .foregroundColor(.white)
                                .font(.title)
                                .scaleEffect(levelScale) // Apply scale effect
                                .animation(.spring(), value: levelScale) // Animate scale
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .frame(width: 200, height: 20)

                                Rectangle()
                                    .foregroundColor(.blue)
                                    .frame(width: levelProgress, height: 20)
                                    .animation(.easeInOut, value: levelProgress)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.top, 50)

                    Spacer()

                    HStack {
                        Button(action: resetData) {
                            Text("Reset Data")
                                .font(.headline)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.leading, 20)

                        Spacer()

                        Button(action: {
                            showAppInfo = true
                        }) {
                            Text("About")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.trailing, 20)

                        // New Clear Emoji Button
                        Button(action: clearEmojis) {
                            Text("Clear Emojis")
                                .font(.headline)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ForEach(0..<emojis.count, id: \.self) { index in
                    Text(emojis[index])
                        .font(.system(size: emojiSizes[index]))
                        .rotationEffect(.degrees(emojiRotations[index]))
                        .position(emojiPositions[index])
                        .animation(.linear(duration: 3.0), value: emojiPositions[index])
                }

                Button(action: spawnEmojis) {
                    Text("Spam Emojis")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 + 50)
            }
            .onAppear {
                loadData()
                startTimer()

                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    updateClickRate()
                }
            }
            .sheet(isPresented: $showAppInfo) {
                AppInfoView(highestClickRate: highestClickRate)
            }
        }
    }

    private func spawnEmojis() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        let numberOfEmojis = Int.random(in: 5...10)
        for _ in 0..<numberOfEmojis {
            let randomEmoji = ["😀", "😂", "🥳", "😍", "😎", "🤖", "👾", "🌟", "🎉", "💖"].randomElement() ?? "😀"
            let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let randomY = CGFloat.random(in: 0...UIScreen.main.bounds.height)
            let randomSize = CGFloat.random(in: 30...100)
            let randomRotation = Double.random(in: 0...360)

            emojis.append(randomEmoji)
            emojiPositions.append(CGPoint(x: randomX, y: randomY))
            emojiSizes.append(randomSize)
            emojiRotations.append(randomRotation)
        }

        totalEmojis += numberOfEmojis
        clickCount += 1
        clickRate += 1
        totalClicksInLastMinute += 1

        checkForLevelUp()
        animateEmojiFall(numberOfEmojis: numberOfEmojis)

        saveData()
    }

    private func checkForLevelUp() {
        if clickCount >= levelClickRequirement {
            level += 1
            levelProgress = 0 // Reset level progress
            
            // Trigger strong haptic feedback
            let strongHaptic = UIImpactFeedbackGenerator(style: .heavy)
            strongHaptic.impactOccurred()
            
            // Scale the level text
            levelScale = 1.5 // Enlarge
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                levelScale = 1.0 // Reset scale after a moment
            }
            
            for _ in 0..<10 {
                emojis.append("🎉")
                let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                emojiPositions.append(CGPoint(x: randomX, y: UIScreen.main.bounds.height))
                emojiSizes.append(CGFloat.random(in: 50...100))
                emojiRotations.append(Double.random(in: 0...360))
            }
        }

        // Calculate the progress within the current level
        if level > 1 {
            let previousLevelRequirement = levelClickRequirement - (level >= 5 ? higherLevelIncrement : levelIncrement)
            levelProgress = CGFloat(clickCount - previousLevelRequirement) / CGFloat(levelClickRequirement - previousLevelRequirement) * 200
        } else {
            levelProgress = CGFloat(clickCount) / CGFloat(levelClickRequirement) * 200 // Start from 0 clicks for level 1
        }
    }

    private func animateEmojiFall(numberOfEmojis: Int) {
        for index in 0..<numberOfEmojis {
            withAnimation(.linear(duration: 3.0)) {
                emojiPositions[emojis.count - numberOfEmojis + index] = CGPoint(x: emojiPositions[emojis.count - numberOfEmojis + index].x, y: UIScreen.main.bounds.height + 100)
            }
        }
    }

    private func updateClickRate() {
        averageClickRate = totalClicksInLastMinute > 0 ? Double(totalClicksInLastMinute) : 0.0
        
        // Update the highest click rate if the current average is higher
        if averageClickRate > highestClickRate {
            highestClickRate = averageClickRate
        }

        totalClicksInLastMinute = 0
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            totalTimeSpent += 1
        }
    }

    private func resetData() {
        clickCount = 0
        totalEmojis = 0
        totalTimeSpent = 0
        clickRate = 0
        highestClickRate = 0
        averageClickRate = 0
        level = 1
        levelProgress = 0.0
        emojis.removeAll()
        emojiPositions.removeAll()
        emojiSizes.removeAll()
        emojiRotations.removeAll()
        
        saveData()
    }

    private func clearEmojis() {
        emojis.removeAll()
        emojiPositions.removeAll()
        emojiSizes.removeAll()
        emojiRotations.removeAll()
    }

    private func loadData() {
        let defaults = UserDefaults.standard
                
                clickCount = defaults.integer(forKey: "clickCount")
                totalEmojis = defaults.integer(forKey: "totalEmojis")
                totalTimeSpent = defaults.integer(forKey: "totalTimeSpent")
                highestClickRate = defaults.double(forKey: "highestClickRate")
                averageClickRate = defaults.double(forKey: "averageClickRate")
                level = defaults.integer(forKey: "level")
                levelProgress = CGFloat(defaults.float(forKey: "levelProgress")) // Change Float to CGFloat

              
              
        
        
    }

    private func saveData() {
        let defaults = UserDefaults.standard
               
               defaults.set(clickCount, forKey: "clickCount")
               defaults.set(totalEmojis, forKey: "totalEmojis")
               defaults.set(totalTimeSpent, forKey: "totalTimeSpent")
               defaults.set(highestClickRate, forKey: "highestClickRate")
               defaults.set(averageClickRate, forKey: "averageClickRate")
               defaults.set(level, forKey: "level")
               defaults.set(Float(levelProgress), forKey: "levelProgress") // Convert CGFloat to Float

      
             
        
    }
}


