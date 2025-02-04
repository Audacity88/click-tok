//
//  ContentView.swift
//  clicktok
//
//  Created by Daniel Gilles on 2/4/25.
//

import SwiftUI
import AVKit
import Appwrite

// MARK: - Models
struct Video: Identifiable, Codable {
    let id: String
    let url: String
    let thumbnailUrl: String
    let caption: String
    let author: String
    var likes: Int
    var comments: Int
    var shares: Int
    let createdAt: TimeInterval
}

// MARK: - View Models
class FeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentIndex = 0
    
    private let appWrite = AppWriteManager.shared
    
    func fetchVideos() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let queries = [
                AppWriteConstants.Queries.orderByCreatedAt(),
                AppWriteConstants.Queries.limit(50)
            ]
            
            let result = try await appWrite.listDocuments(
                databaseId: AppWriteConstants.databaseId,
                collectionId: AppWriteConstants.Collections.videos,
                queries: queries
            )
            
            await MainActor.run {
                self.videos = result.documents.compactMap { document in
                    try? JSONDecoder().decode(Video.self, from: document.data)
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                print("Error fetching videos: \(error.localizedDescription)")
            }
        }
    }
    
    func likeVideo(_ video: Video) async {
        guard let currentUser = try? await appWrite.getCurrentUser() else { return }
        
        do {
            // Create a like document
            let likeData: [String: Any] = [
                "userId": currentUser.$id,
                "videoId": video.id,
                "createdAt": Date().timeIntervalSince1970
            ]
            
            try await appWrite.createDocument(
                databaseId: AppWriteConstants.databaseId,
                collectionId: AppWriteConstants.Collections.likes,
                documentId: ID.unique(),
                data: likeData
            )
            
            // Update video likes count
            let updatedData: [String: Any] = [
                "likes": video.likes + 1
            ]
            
            try await appWrite.updateDocument(
                databaseId: AppWriteConstants.databaseId,
                collectionId: AppWriteConstants.Collections.videos,
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

// MARK: - Views
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
                AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                }
                .edgesIgnoringSafeArea(.all)
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
                        
                        Button(action: { /* Comment action */ }) {
                            VStack {
                                Image(systemName: "message.fill")
                                    .font(.title)
                                Text("\(video.comments)")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: { /* Share action */ }) {
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
            if let url = URL(string: video.url) {
                let player = AVPlayer(url: url)
                self.player = player
                player.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
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
        .task {
            await viewModel.fetchVideos()
        }
        .refreshable {
            await viewModel.fetchVideos()
        }
    }
}

// MARK: - Preview
struct ContentView: View {
    var body: some View {
        FeedView()
    }
}

#Preview {
    ContentView()
}
