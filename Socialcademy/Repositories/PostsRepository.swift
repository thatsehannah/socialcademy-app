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
    func fetchPosts() async throws -> [Post]
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
    func favorite(_ post: Post) async throws
    func unfavorite(_ post: Post) async throws
}

struct PostsRepository: PostsRepositoryProtocol {
    let postsReference = Firestore.firestore().collection("posts_v1")
    
    //creates the given post in the posts collection
    func create(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString) //uses the post's UUID string as a document path
        try await document.setData(from: post)
    }
    
    //fetches all of the posts from Firestore and return them in an array full of Post objects
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await postsReference
            .order(by: "timestamp", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)
        }
    }
    
    //deletes the given post in the posts collection
    func delete(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.delete()
    }
    
    func favorite(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(["isFavorite": true], merge: true)
    }
    
    func unfavorite(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(["isFavorite": false], merge: true)
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
    let state: Loadable<[Post]>
                            
    //returns an empty array
    func fetchPosts() async throws -> [Post] {
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
