import Foundation
import Appwrite

enum Models {
    struct Video: Codable, Identifiable {
        let documentId: String
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
        
        var id: String { documentId }
        
        // Computed property for thumbnail URL
        var thumbnailUrl: URL? {
            AppWriteManager.shared.getFilePreview(
                bucketId: AppWriteConstants.Buckets.thumbnails,
                fileId: thumbnailFileId
            )
        }
        
        // Computed property for video URL
        var videoUrl: URL? {
            AppWriteManager.shared.getFileView(
                bucketId: AppWriteConstants.Buckets.videos,
                fileId: videoFileId
            )
        }
        
        private enum CodingKeys: String, CodingKey {
            case documentId = "$id"
            case title
            case caption
            case authorId
            case author
            case videoFileId
            case thumbnailFileId
            case likes
            case comments
            case shares
            case createdAt
        }
    }
    
    struct User: Codable, Identifiable {
        let documentId: String
        let username: String
        let name: String
        let bio: String?
        let avatarUrl: String?
        let followersCount: Int
        let followingCount: Int
        let videosCount: Int
        let createdAt: Double
        
        var id: String { documentId }
        
        private enum CodingKeys: String, CodingKey {
            case documentId = "$id"
            case username
            case name
            case bio
            case avatarUrl
            case followersCount
            case followingCount
            case videosCount
            case createdAt
        }
    }
    
    struct Comment: Codable, Identifiable {
        let documentId: String
        let userId: String
        let author: String
        let videoId: String
        let text: String
        let createdAt: Double
        
        var id: String { documentId }
        
        private enum CodingKeys: String, CodingKey {
            case documentId = "$id"
            case userId
            case author
            case videoId
            case text
            case createdAt
        }
    }
} 