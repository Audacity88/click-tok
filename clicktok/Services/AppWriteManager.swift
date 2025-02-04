import Foundation
import Appwrite

class AppWriteManager {
    static let shared = AppWriteManager()
    
    private let client: Client
    private let account: Account
    private let storage: Storage
    private let databases: Databases
    
    private init() {
        client = Client()
            .setEndpoint(AppWriteConstants.endpoint)
            .setProject(AppWriteConstants.projectId)
            .setSelfSigned(true) // Only for development
        
        account = Account(client)
        storage = Storage(client)
        databases = Databases(client)
    }
    
    // MARK: - Authentication
    
    func createAccount(email: String, password: String, name: String) async throws -> User {
        return try await account.create(
            userId: ID.unique(),
            email: email,
            password: password,
            name: name
        )
    }
    
    func login(email: String, password: String) async throws -> Session {
        return try await account.createEmailSession(
            email: email,
            password: password
        )
    }
    
    func logout() async throws {
        try await account.deleteSession(sessionId: "current")
    }
    
    func getCurrentUser() async throws -> User {
        return try await account.get()
    }
    
    // MARK: - Database Operations
    
    func listDocuments(
        databaseId: String,
        collectionId: String,
        queries: [String]? = nil
    ) async throws -> DocumentList {
        return try await databases.listDocuments(
            databaseId: databaseId,
            collectionId: collectionId,
            queries: queries
        )
    }
    
    func createDocument(
        databaseId: String,
        collectionId: String,
        documentId: String,
        data: [String: Any]
    ) async throws -> Document {
        return try await databases.createDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: data
        )
    }
    
    func updateDocument(
        databaseId: String,
        collectionId: String,
        documentId: String,
        data: [String: Any]
    ) async throws -> Document {
        return try await databases.updateDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: data
        )
    }
    
    func deleteDocument(
        databaseId: String,
        collectionId: String,
        documentId: String
    ) async throws {
        try await databases.deleteDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId
        )
    }
    
    // MARK: - Storage Operations
    
    func uploadVideo(fileData: Data, name: String) async throws -> File {
        return try await storage.createFile(
            bucketId: AppWriteConstants.Buckets.videos,
            fileId: ID.unique(),
            file: InputFile.fromData(fileData, name: name)
        )
    }
    
    func uploadThumbnail(fileData: Data, name: String) async throws -> File {
        return try await storage.createFile(
            bucketId: AppWriteConstants.Buckets.thumbnails,
            fileId: ID.unique(),
            file: InputFile.fromData(fileData, name: name)
        )
    }
    
    func getFileView(bucketId: String, fileId: String) async throws -> URL {
        return try await storage.getFileView(
            bucketId: bucketId,
            fileId: fileId
        )
    }
    
    func deleteFile(bucketId: String, fileId: String) async throws {
        try await storage.deleteFile(
            bucketId: bucketId,
            fileId: fileId
        )
    }
} 