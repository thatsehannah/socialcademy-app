//
//  AuthService.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/23/23.
//
//  This class is a mix between a view model and a repository

import Foundation
import FirebaseAuth

@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    
    private let auth = Auth.auth()
    private var listener: AuthStateDidChangeListenerHandle?
    
    init() {
        listener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user.map(User.init(from:))
        }
    }
    
    //creates an account with the given email and password. Then, when the account is created, it updates the account with the given name
    func createAccount(name: String, email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        user?.name = name
    }
    
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func updateProfileImage(to imageFileURL: URL?) async throws {
        guard let user = auth.currentUser else {
            preconditionFailure("Cannot update profile for nil user")
        }
        guard let imageFileURL = imageFileURL else {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.photoURL = nil
            try await changeRequest.commitChanges()
            if let photoURL = user.photoURL {
                try await StorageFile.atURL(photoURL).delete()
            }
            return
        }
        
        let newPhotoURL = try await StorageFile
            .with(namespace: "users", identifier: user.uid)
            .putFile(from: imageFileURL)
            .getDownloadURL()
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = newPhotoURL
        try await changeRequest.commitChanges()
    }
}

private extension FirebaseAuth.User {
    func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
        var profileChangeRequest = createProfileChangeRequest()
        profileChangeRequest[keyPath: keyPath] = newValue
        try await profileChangeRequest.commitChanges()
    }
}

private extension User {
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? "No username"
        self.imageURL = firebaseUser.photoURL
    }
}
