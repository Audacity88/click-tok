import SwiftUI
import Appwrite
import AVKit

struct Video: Codable, Identifiable {
    let $id: String
    let title: String
    let caption: String
    let authorId: String
    let author: String
    let videoFileId: String
    let thumbnailFileId: String
    let likes: Int
    let comments: Int
    let shares: Int
    let createdAt: Double
    
    var id: String { $id } // For Identifiable conformance
    
    // Computed property for thumbnail URL
    var thumbnailUrl: URL? {
        AppWriteManager.shared.getFilePreview(
            bucketId: "thumbnails",
            fileId: thumbnailFileId
        )
    }
    
    // Computed property for video URL
    var videoUrl: URL? {
        AppWriteManager.shared.getFileView(
            bucketId: "videos",
            fileId: videoFileId
        )
    }
}

@MainActor
class FeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentIndex: Int = 0
    
    private let appwrite = AppWriteManager.shared
    
    func fetchVideos() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let queries = [
                Query.orderDesc("createdAt"),
                Query.limit(50)
            ]
            
            let result = try await appwrite.databases.listDocuments(
                databaseId: AppWriteManager.databaseId,
                collectionId: "videos",
                queries: queries
            )
            
            self.videos = result.documents.compactMap { document in
                try? document.decode()
            }
        } catch {
            self.error = error
            print("Error fetching videos: \(error.localizedDescription)")
        }
    }
    
    func likeVideo(_ video: Video) async {
        guard let currentUser = try? await appwrite.account.get() else { return }
        
        do {
            // Check if user already liked the video
            let queries = [
                Query.equal("userId", currentUser.$id),
                Query.equal("videoId", video.id)
            ]
            
            let existingLikes = try await appwrite.databases.listDocuments(
                databaseId: AppWriteManager.databaseId,
                collectionId: "likes",
                queries: queries
            )
            
            // If already liked, return
            if existingLikes.total > 0 {
                return
            }
            
            // Create a like document
            let likeData: [String: Any] = [
                "userId": currentUser.$id,
                "videoId": video.id,
                "createdAt": Date().timeIntervalSince1970
            ]
            
            try await appwrite.databases.createDocument(
                databaseId: AppWriteManager.databaseId,
                collectionId: "likes",
                documentId: ID.unique(),
                data: likeData
            )
            
            // Update video likes count
            let updatedData: [String: Any] = [
                "likes": video.likes + 1
            ]
            
            try await appwrite.databases.updateDocument(
                databaseId: AppWriteManager.databaseId,
                collectionId: "videos",
                documentId: video.id,
                data: updatedData
            )
            
            // Refresh videos
            await fetchVideos()
        } catch {
            print("Error liking video: \(error.localizedDescription)")
        }
    }
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.videos.isEmpty {
                    Text("No videos yet")
                        .foregroundColor(.gray)
                } else {
                    TabView(selection: $viewModel.currentIndex) {
                        ForEach(viewModel.videos.indices, id: \.self) { index in
                            VideoPlayerView(video: viewModel.videos[index]) {
                                Task {
                                    await viewModel.likeVideo(viewModel.videos[index])
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()
                }
            }
            .navigationTitle("For You")
            .task {
                await viewModel.fetchVideos()
            }
            .refreshable {
                await viewModel.fetchVideos()
            }
        }
    }
}

struct VideoPlayerView: View {
    let video: Video
    @State private var player: AVPlayer?
    let onLike: () -> Void
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Thumbnail view while video loads
                if let thumbnailUrl = video.thumbnailUrl {
                    AsyncImage(url: thumbnailUrl) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
            
            // Overlay content
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("@\(video.author)")
                            .font(.headline)
                        Text(video.caption)
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    
                    Spacer()
                    
                    // Interaction buttons
                    VStack(spacing: 20) {
                        Button(action: onLike) {
                            VStack {
                                Image(systemName: "heart.fill")
                                    .font(.title)
                                Text("\(video.likes)")
                                    .font(.caption)
                            }
                        }
                        
                        NavigationLink(destination: CommentsView(videoId: video.id)) {
                            VStack {
                                Image(systemName: "message.fill")
                                    .font(.title)
                                Text("\(video.comments)")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: shareVideo) {
                            VStack {
                                Image(systemName: "square.and.arrow.up.fill")
                                    .font(.title)
                                Text("\(video.shares)")
                                    .font(.caption)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                }
                .padding()
            }
        }
        .onAppear {
            // Initialize and play video
            if let videoUrl = video.videoUrl {
                let player = AVPlayer(url: videoUrl)
                self.player = player
                player.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func shareVideo() {
        guard let url = video.videoUrl else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
} 