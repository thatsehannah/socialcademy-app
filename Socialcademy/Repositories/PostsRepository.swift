//
//  PostsRepository.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/12/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol PostsRepositoryProtocol {
    func fetchAllPosts() async throws -> [Post]
    func fetchFavoritedPosts() async throws -> [Post]
    func fetchPosts(by author: User) async throws -> [Post]
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
    func favorite(_ post: Post) async throws
    func unfavorite(_ post: Post) async throws
    var currentUser: User { get }
}

struct PostsRepository: PostsRepositoryProtocol {
    let currentUser: User
    
    let postsReference = Firestore.firestore().collection("posts_v2")
    let favoritesReference = Firestore.firestore().collection("favorites")
    
    //creates the given post in the posts collection
    func create(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString) //uses the post's UUID string as a document path
        try await document.setData(from: post)
    }
    
    //fetches all of the posts from Firestore and returns them in an array of Post objects
    func fetchAllPosts() async throws -> [Post] {
        return try await fetchPosts(from: postsReference)
    }
    
    //fetches all of the posts from Firestore where the isFavorite field is equal to true and returns them in an array of Post objects
    func fetchFavoritedPosts() async throws -> [Post] {
        let favorites = try await fetchFavorites()
        guard !favorites.isEmpty else { return [] }
        let posts = try await postsReference
            .whereField("id", in: favorites.map(\.uuidString))
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Post.self)
        return posts.map { post in
            post.setting(\.isFavorite, to: true)
        }
    }
    
    func fetchPosts(by author: User) async throws -> [Post] {
        return try await fetchPosts(from: postsReference.whereField("author.id", isEqualTo: author.id))
    }
    
    //deletes the given post in the posts collection
    func delete(_ post: Post) async throws {
        precondition(canDelete(post))
        let document = postsReference.document(post.id.uuidString)
        try await document.delete()
    }
    
    func favorite(_ post: Post) async throws {
        let favorite = Favorite(postId: post.id, userId: currentUser.id)
        let document = favoritesReference.document(favorite.id)
        try await document.setData(from: favorite)
    }
    
    func unfavorite(_ post: Post) async throws {
        let favorite = Favorite(postId: post.id, userId: currentUser.id)
        let document = favoritesReference.document(favorite.id)
        try await document.delete()
    }
}

private extension PostsRepository {
    struct Favorite: Codable, Identifiable {
        var id: String {
            postId.uuidString + "-" + userId
        }
        let postId: Post.ID
        let userId: User.ID
    }
    
    func fetchFavorites() async throws -> [Post.ID] {
        return try await favoritesReference
            .whereField("userId", isEqualTo: currentUser.id)
            .getDocuments(as: Favorite.self)
            .map(\.postId)
    }
    
    func fetchPosts(from query: Query) async throws -> [Post] {
        let (posts, favorites) = try await (
            query.order(by: "timestamp", descending: true).getDocuments(as: Post.self),
            fetchFavorites()
        )
        return posts.map { post in
            post.setting(\.isFavorite, to: favorites.contains(post.id))
        }
    }
}

extension PostsRepositoryProtocol {
    func canDelete(_ post: Post) -> Bool {
        post.author.id == currentUser.id //returns true when the post's author ID mathches the ID of the current user
    }
}

private extension Post {
    func setting<T>(_ property: WritableKeyPath<Post, T>, to newValue: T) -> Post {
        var post = self
        post[keyPath: property] = newValue
        return post
    }
}

private extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: type)
        }
    }
}

private extension DocumentReference {
    
    //Creates an async wrapper for the setData(from:) method in the Cloud Firestore SDK
    //The original method throws for encoding errors, but passes all other errors to an optional completion handler, which
    //means we'll have no way of knowing if our document was saved unless we provide a completion handler
    //The wrapper throws any errors that need to be brought to our attention - and if it doesn't throw an error, we know
    //the document was saved successfully
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}

#if DEBUG //directive which means the code will only be compiled in debug builds of the app
struct PostsRepositoryStub: PostsRepositoryProtocol {
    var currentUser = User.testUser
    
    let state: Loadable<[Post]>
                            
    //returns an empty array
    func fetchAllPosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func fetchFavoritedPosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func fetchPosts(by author: User) async throws -> [Post] {
        return try await state.simulate()
    }
    
    //does nothing
    func create(_ post: Post) async throws {}
    
    //also does nothing
    func delete(_ post: Post) async throws {}
    
    //you get the picture atp...
    func favorite(_ post: Post) async throws {}
    
    func unfavorite(_ post: Post) async throws {}
}
#endif


