//
//  ContentView.swift
//  EMOJI
//
//  Created by Shreyansh Mishra on 30/09/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var emojis: [String] = []
    @State private var emojiPositions: [CGPoint] = [] // Store positions as CGPoint
    @State private var emojiSizes: [CGFloat] = []
    @State private var emojiRotations: [Double] = [] // Store random rotations
    
    @State private var clickCount: Int = 0 // Count number of clicks
    @State private var totalEmojis: Int = 0 // Total number of emojis spawned
    @State private var totalTimeSpent: Int = 0 // Total time spent in seconds
    @State private var timer: Timer? // Timer to keep track of time

    @State private var showAppInfo: Bool = false // State variable to show app info view

    var body: some View {
        NavigationStack { // Use NavigationStack for navigation capabilities
            ZStack {
                Color.black.ignoresSafeArea() // Set background color to black
                
                VStack {
                    // Display the count of clicks and total emojis centered
                    VStack(spacing: 10) {
                        Text("Button Clicked: \(clickCount) times")
                            .foregroundColor(.white)
                            .font(.title2) // Increased font size
                        Text("Total Emojis Spawned: \(totalEmojis)")
                            .foregroundColor(.white)
                            .font(.title2) // Increased font size
                        Text("Total Time Spent: \(totalTimeSpent / 60) min \(totalTimeSpent % 60) sec") // Display time in minutes and seconds
                            .foregroundColor(.white)
                            .font(.title2) // Increased font size
                    }
                    .padding(.top, 50) // Add padding to the top
                    
                    Spacer() // Push the buttons down

                    // Bottom button layout
                    HStack {
                        Button(action: resetData) {
                            Text("Reset Data")
                                .font(.headline)
                                .padding()
                                .background(Color.red) // Change to your desired color
                                .foregroundColor(.white) // Text color
                                .cornerRadius(10)
                        }
                        .padding(.leading, 20) // Add padding on the leading side

                        Spacer() // Push the new button to the right
                        
                        Button(action: {
                            showAppInfo = true // Show app info view
                        }) {
                            Text("About")
                                .font(.headline)
                                .padding()
                                .background(Color.blue) // Change to your desired color
                                .foregroundColor(.white) // Text color
                                .cornerRadius(10)
                        }
                        .padding(.trailing, 20) // Add padding on the trailing side
                    }
                    .padding(.bottom, 50) // Add padding to the bottom
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the VStack takes the full screen height
                
                ForEach(0..<emojis.count, id: \.self) { index in
                    Text(emojis[index])
                        .font(.system(size: emojiSizes[index])) // Use variable size
                        .rotationEffect(.degrees(emojiRotations[index])) // Apply random rotation
                        .position(emojiPositions[index]) // Use CGPoint for position
                        .animation(.linear(duration: 3.0), value: emojiPositions[index])
                }
                
                Button(action: {
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                    let numberOfEmojis = Int.random(in: 5...10) // Generate between 5 and 10 emojis
                    for _ in 0..<numberOfEmojis {
                        let randomEmoji = ["😀", "😂", "🥳", "😍", "😎", "🤖", "👾", "🌟", "🎉", "💖"].randomElement() ?? "😀"
                        let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width) // Random X position
                        let randomY = CGFloat.random(in: 0...UIScreen.main.bounds.height) // Random Y position for spawning
                        let randomSize = CGFloat.random(in: 30...100) // Size between 30 and 100
                        let randomRotation = Double.random(in: 0...360) // Random rotation between 0 and 360 degrees

                        emojis.append(randomEmoji)
                        emojiPositions.append(CGPoint(x: randomX, y: randomY)) // Use CGPoint for positions
                        emojiSizes.append(randomSize)
                        emojiRotations.append(randomRotation) // Add random rotation
                    }

                    // Update total emojis spawned and click count
                    totalEmojis += numberOfEmojis
                    clickCount += 1

                    // Animate the falling
                    for index in 0..<numberOfEmojis {
                        withAnimation(.linear(duration: 3.0)) {
                            emojiPositions[emojis.count - numberOfEmojis + index] = CGPoint(x: emojiPositions[emojis.count - numberOfEmojis + index].x, y: UIScreen.main.bounds.height + 100) // Move down
                        }
                    }

                    // Save click count and total emojis to UserDefaults
                    UserDefaults.standard.set(totalEmojis, forKey: "totalEmojis")
                    UserDefaults.standard.set(clickCount, forKey: "clickCount")
                    
                }) {
                    Text("Spam Emojis")
                        .font(.title)
                        .padding()
                        .background(Color.blue) // Change this to your desired color
                        .foregroundColor(.white) // Text color
                        .cornerRadius(10)
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 + 50) // Position button lower
            }
            .onAppear {
                // Load saved data from UserDefaults
                totalEmojis = UserDefaults.standard.integer(forKey: "totalEmojis")
                clickCount = UserDefaults.standard.integer(forKey: "clickCount")
                totalTimeSpent = UserDefaults.standard.integer(forKey: "totalTimeSpent")

                // Start the timer
                startTimer()
            }
            .sheet(isPresented: $showAppInfo) { // Present App Info view as a sheet
                AppInfoView()
            }
        }
    }

    // Function to start the timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            totalTimeSpent += 1 // Increment total time spent every second
            UserDefaults.standard.set(totalTimeSpent, forKey: "totalTimeSpent") // Save to UserDefaults
        }
    }

    // Function to reset all data
    private func resetData() {
        clickCount = 0
        totalEmojis = 0
        totalTimeSpent = 0
        emojis.removeAll()
        emojiPositions.removeAll()
        emojiSizes.removeAll()
        emojiRotations.removeAll()

        // Reset UserDefaults
        UserDefaults.standard.removeObject(forKey: "totalEmojis")
        UserDefaults.standard.removeObject(forKey: "clickCount")
        UserDefaults.standard.removeObject(forKey: "totalTimeSpent")
    }
}
