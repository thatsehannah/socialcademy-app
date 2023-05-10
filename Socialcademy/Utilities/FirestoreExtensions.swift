//
//  FirestoreExtensions.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 5/10/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: type)
        }
    }
}

extension DocumentReference {
    
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
