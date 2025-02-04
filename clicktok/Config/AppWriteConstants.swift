import Foundation

enum AppWriteConstants {
    static let endpoint = "https://cloud.appwrite.io/v1" // Replace with your endpoint if self-hosted
    static let projectId = "67a24702001e52a8b032" // TODO: Replace with your Appwrite project ID
    static let databaseId = "67a247c300211b53cde4" // TODO: Replace with your database ID
    
    enum Collections {
        static let videos = "videos"
        static let likes = "likes"
        static let comments = "comments"
        static let users = "users"
    }
    
    enum Buckets {
        static let videos = "videos"
        static let thumbnails = "thumbnails"
    }
    
    enum Queries {
        static func orderByCreatedAt(ascending: Bool = false) -> String {
            return ascending ? "createdAt" : "-createdAt"
        }
        
        static func limit(_ value: Int) -> String {
            return "limit(\(value))"
        }
        
        static func offset(_ value: Int) -> String {
            return "offset(\(value))"
        }
    }
} 