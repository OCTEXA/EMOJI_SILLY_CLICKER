//octexa
import SwiftUI

struct AppInfoView: View {
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the view
    var highestClickRate: Double // Pass highest click rate

    var body: some View {
        VStack {
            Text("EMOJI App")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white) // Set text color to white
            
            Text("Version: 1.1.0")
                .font(.title2)
                .padding(.bottom, 20)
                .foregroundColor(.white) // Set text color to white

            Text("This app allows you to spam random emojis across the screen.")
                .padding()
                .foregroundColor(.white) // Set text color to white
            
            
            Text("Tap the button to create emojis that fall randomly from the screen.")
                .padding()
                .foregroundColor(.white) // Set text color to white

            // Display the highest click rate
            Text("Highest Click Rate: \(String(format: "%.1f", highestClickRate)) clicks/min")
                .font(.title2)
                .padding(.top, 20)
                .foregroundColor(.white)
            
            Text("Version 1.1.0 Added Level up system(+250 Clicks per level),clear emoji buttun if emoji gets stuck")
                .padding()
                .foregroundColor(.white) // Set text color to white
            
            Text("Octexa@2024 GitHub")
                .padding()
                .foregroundColor(.white) // Set text color to white

            Spacer()
            
            Button(action: {
                dismiss() // Dismiss the view when back button is pressed
            }) {
                Text("Back")
                    .font(.headline)
                    .padding()
                    .background(Color.blue) // Change to your desired color
                    .foregroundColor(.white) // Text color
                    .cornerRadius(10)
            }
            .padding(.bottom, 20) // Padding from bottom
        }
        .background(Color.black) // Set background color to black
        .navigationTitle("App Info") // Title for the navigation bar
        .navigationBarTitleDisplayMode(.inline) // Display title inline
        .padding()
        .ignoresSafeArea() // Ensure the background covers the whole area
    }
}
