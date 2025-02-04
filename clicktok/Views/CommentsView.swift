import SwiftUI
import Appwrite

struct Comment: Codable, Identifiable {
    let $id: String
    let userId: String
    let videoId: String
    let text: String
    let createdAt: Double
    
    var id: String { $id }
}

@MainActor
class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var newCommentText = ""
    
    private let videoId: String
    private let appwrite = AppWriteManager.shared
    
    init(videoId: String) {
        self.videoId = videoId
    }
    
    func fetchComments() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let queries = [
                Query.equal("videoId", videoId),
                Query.orderDesc("createdAt"),
                Query.limit(100)
            ]
            
            let result = try await appwrite.databases.listDocuments(
                databaseId: AppWriteManager.databaseId,
                collectionId: "comments",
                queries: queries
            )
            
            self.comments = result.documents.compactMap { document in
                try? document.decode()
            }
        } catch {
            self.error = error
            print("Error fetching comments: \(error.localizedDescription)")
        }
    }
    
    func addComment() async {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUser = try? await appwrite.account.get() else {
            return
        }
        
        do {
            // Create comment document
            let commentData: [String: Any] = [
                "userId": currentUser.$id,
                "videoId": videoId,
                "text": newCommentText,
                "createdAt": Date().timeIntervalSince1970
            ]
            
            try await appwrite.databases.createDocument(
                databaseId: AppWriteManager.databaseId,
                collectionId: "comments",
                documentId: ID.unique(),
                data: commentData
            )
            
            // Update video comments count
            let videoDoc = try await appwrite.databases.getDocument(
                databaseId: AppWriteManager.databaseId,
                collectionId: "videos",
                documentId: videoId
            )
            
            if let currentCount = try? videoDoc.decode() as Video {
                let updatedData: [String: Any] = [
                    "comments": currentCount.comments + 1
                ]
                
                try await appwrite.databases.updateDocument(
                    databaseId: AppWriteManager.databaseId,
                    collectionId: "videos",
                    documentId: videoId,
                    data: updatedData
                )
            }
            
            // Clear text and refresh comments
            await MainActor.run {
                self.newCommentText = ""
            }
            await fetchComments()
        } catch {
            print("Error adding comment: \(error.localizedDescription)")
        }
    }
}

struct CommentsView: View {
    let videoId: String
    @StateObject private var viewModel: CommentsViewModel
    @FocusState private var isCommentFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    init(videoId: String) {
        self.videoId = videoId
        self._viewModel = StateObject(wrappedValue: CommentsViewModel(videoId: videoId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Comments list
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.comments.isEmpty {
                Text("No comments yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.comments) { comment in
                        CommentCell(comment: comment)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                    .onChange(of: viewModel.comments.count) { _ in
                        if let lastComment = viewModel.comments.first {
                            withAnimation {
                                proxy.scrollTo(lastComment.id, anchor: .top)
                            }
                        }
                    }
                }
            }
            
            // Comment input
            VStack(spacing: 8) {
                Divider()
                HStack {
                    TextField("Add a comment...", text: $viewModel.newCommentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isCommentFieldFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            Task {
                                await viewModel.addComment()
                            }
                        }
                    
                    Button(action: {
                        Task {
                            await viewModel.addComment()
                            isCommentFieldFocused = false
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color(UIColor.systemBackground))
            .offset(y: -keyboardHeight) // Adjust for keyboard
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchComments()
        }
        .onAppear {
            // Subscribe to keyboard notifications
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                keyboardHeight = keyboardFrame.height
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
        }
        // Dismiss keyboard when dragging
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                isCommentFieldFocused = false
            }
        )
    }
}

struct CommentCell: View {
    let comment: Comment
    @State private var author: String = "User"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(author)
                .font(.headline)
            Text(comment.text)
                .font(.body)
            Text(Date(timeIntervalSince1970: comment.createdAt), style: .relative)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .task {
            // Fetch author name
            do {
                let userDoc = try await AppWriteManager.shared.databases.getDocument(
                    databaseId: AppWriteManager.databaseId,
                    collectionId: "users",
                    documentId: comment.userId
                )
                if let user = try? userDoc.decode() as User {
                    await MainActor.run {
                        self.author = user.name
                    }
                }
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationView {
        CommentsView(videoId: "preview-video-id")
    }
} 