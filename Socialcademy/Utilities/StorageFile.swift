//
//  StorageFile.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 5/11/23.
//

import Foundation

import FirebaseStorage

struct StorageFile {
    private let storageReference: StorageReference
    
    //uploads the file to Firebase Storage
    func putFile(from fileURL: URL) async throws -> Self {
        _ = try await storageReference.putFileAsync(from: fileURL)
        return self
    }
    
    //retrieves the file's permanent URL
    func getDownloadURL() async throws -> URL {
        return try await storageReference.downloadURL()
    }
    
    func delete() async throws {
        try await storageReference.delete()
    }
}

extension StorageFile {
    private static let storage = Storage.storage()
    
    //namespace will be posts and the identifier will be the postId
    static func with(namespace: String, identifier: String) -> StorageFile {
        let path = "\(namespace)/\(identifier)"
        let storageReference = storage.reference().child(path)
        return StorageFile(storageReference: storageReference)
    }
    
    //allows access to the file at a given download URL
    static func atURL(_ downloadURL: URL) -> StorageFile {
        let storageReference = storage.reference(forURL: downloadURL.absoluteString)
        return StorageFile(storageReference: storageReference)
    }
}
