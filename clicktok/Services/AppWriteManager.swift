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
        return try await account.createSession(
            email: email,
            password: password
        )
    }
    
    func logout() async throws {
        _ = try await account.deleteSession(sessionId: "current")
    }
    
    func getCurrentUser() async throws -> User {
        return try await account.get()
    }
    
    // MARK: - Database Operations
    
    func listDocuments<T: Codable>(
        databaseId: String,
        collectionId: String,
        queries: [String]? = nil
    ) async throws -> DocumentList<T> {
        let result = try await databases.listDocuments(
            databaseId: databaseId,
            collectionId: collectionId,
            queries: queries
        )
        
        // Convert the generic document list to our specific type
        let documents = try result.documents.map { doc -> T in
            let decoder = JSONDecoder()
            let data = try JSONSerialization.data(withJSONObject: doc.data)
            return try decoder.decode(T.self, from: data)
        }
        
        return DocumentList(
            total: result.total,
            documents: documents
        )
    }
    
    func createDocument<T: Codable>(
        databaseId: String,
        collectionId: String,
        documentId: String,
        data: [String: Any]
    ) async throws -> Document<T> {
        let result = try await databases.createDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: data
        )
        
        // Convert the generic document to our specific type
        let decoder = JSONDecoder()
        let jsonData = try JSONSerialization.data(withJSONObject: result.data)
        let decodedData = try decoder.decode(T.self, from: jsonData)
        
        return Document(
            $id: result.$id,
            $collectionId: result.$collectionId,
            $databaseId: result.$databaseId,
            $createdAt: result.$createdAt,
            $updatedAt: result.$updatedAt,
            $permissions: result.$permissions,
            data: decodedData
        )
    }
    
    func updateDocument<T: Codable>(
        databaseId: String,
        collectionId: String,
        documentId: String,
        data: [String: Any]
    ) async throws -> Document<T> {
        let result = try await databases.updateDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: data
        )
        
        // Convert the generic document to our specific type
        let decoder = JSONDecoder()
        let jsonData = try JSONSerialization.data(withJSONObject: result.data)
        let decodedData = try decoder.decode(T.self, from: jsonData)
        
        return Document(
            $id: result.$id,
            $collectionId: result.$collectionId,
            $databaseId: result.$databaseId,
            $createdAt: result.$createdAt,
            $updatedAt: result.$updatedAt,
            $permissions: result.$permissions,
            data: decodedData
        )
    }
    
    func deleteDocument(
        databaseId: String,
        collectionId: String,
        documentId: String
    ) async throws {
        _ = try await databases.deleteDocument(
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
    
    func getFileView(bucketId: String, fileId: String) -> URL? {
        let urlString = storage.getFileView(
            bucketId: bucketId,
            fileId: fileId
        ).description
        return URL(string: urlString)
    }
    
    func getFilePreview(bucketId: String, fileId: String) -> URL? {
        let urlString = storage.getFilePreview(
            bucketId: bucketId,
            fileId: fileId
        ).description
        return URL(string: urlString)
    }
    
    func deleteFile(bucketId: String, fileId: String) async throws {
        _ = try await storage.deleteFile(
            bucketId: bucketId,
            fileId: fileId
        )
    }
} 