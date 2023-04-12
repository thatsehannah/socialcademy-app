//
//  PostsRepository.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/12/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PostsRepository {
    static let postsReference = Firestore.firestore().collection("posts")
    
    //creates the given post in the posts collection
    static func create(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString) //uses the post's UUID string as a document path
        try await document.setData(from: post)
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
