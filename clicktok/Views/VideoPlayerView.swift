import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL?
    @State private var player: AVPlayer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView()
            }
            
            // Dismiss button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            guard let url = videoURL else {
                dismiss()
                return
            }
            player = AVPlayer(url: url)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    VideoPlayerView(videoURL: URL(string: "https://example.com/video.mp4"))
} 