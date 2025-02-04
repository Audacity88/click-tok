import SwiftUI
import Appwrite

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var videos: [Models.Video] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentIndex = 0
    
    private let appWrite = AppWriteManager.shared
    
    func fetchVideos() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let queries = [
                Query.orderDesc("createdAt"),
                Query.limit(50)
            ]
            
            let result: DocumentList<Models.Video> = try await appWrite.listDocuments(
                databaseId: AppWriteConstants.databaseId,
                collectionId: AppWriteConstants.Collections.videos,
                queries: queries
            )
            
            self.videos = result.documents
        } catch {
            self.error = error
            print("Error fetching videos: \(error.localizedDescription)")
        }
    }
    
    func likeVideo(_ video: Models.Video) async {
        guard let currentUser = try? await appWrite.getCurrentUser() else { return }
        
        do {
            // Check if user already liked the video
            let queries = [
                Query.equal(key: "userId", value: currentUser.$id),
                Query.equal(key: "videoId", value: video.id)
            ]
            
            let existingLikes: DocumentList<[String: String]> = try await appWrite.listDocuments(
                databaseId: AppWriteConstants.databaseId,
                collectionId: AppWriteConstants.Collections.likes,
                queries: queries
            )
            
            // If user hasn't liked the video yet
            if existingLikes.documents.isEmpty {
                // Create a like document
                let likeData: [String: Any] = [
                    "userId": currentUser.$id,
                    "videoId": video.id,
                    "createdAt": Date().timeIntervalSince1970
                ]
                
                let _: Document<[String: String]> = try await appWrite.createDocument(
                    databaseId: AppWriteConstants.databaseId,
                    collectionId: AppWriteConstants.Collections.likes,
                    documentId: ID.unique(),
                    data: likeData
                )
                
                // Update video likes count
                let updatedData: [String: Any] = [
                    "likes": video.likes + 1
                ]
                
                let _: Document<Models.Video> = try await appWrite.updateDocument(
                    databaseId: AppWriteConstants.databaseId,
                    collectionId: AppWriteConstants.Collections.videos,
                    documentId: video.id,
                    data: updatedData
                )
                
                // Refresh videos
                await fetchVideos()
            }
        } catch {
            print("Error liking video: \(error.localizedDescription)")
        }
    }
} 