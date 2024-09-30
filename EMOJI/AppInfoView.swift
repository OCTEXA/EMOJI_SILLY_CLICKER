import SwiftUI

struct AppInfoView: View {
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the view

    var body: some View {
        VStack {
            Text("SILLY EMOJI CLICKER")
                .font(.largeTitle)
                .padding()
            Text("Version: 1.0.0")
                .font(.title2)
                .padding(.bottom, 20)
            Text("This app allows you to spam random emojis across the screen .")
                .padding()
            Text("Tap the button to create emojis that fall randomly from the screen.")
                .padding()

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
        .navigationTitle("App Info") // Title for the navigation bar
        .navigationBarTitleDisplayMode(.inline) // Display title inline
        .padding()
    }
}
