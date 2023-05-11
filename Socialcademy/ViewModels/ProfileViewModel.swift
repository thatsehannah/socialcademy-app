//
//  ProfileViewModel.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 5/11/23.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject, StateManager {
    @Published var name: String
    @Published var isWorking = false
    
    //property observer monitors when this property is updated, in which it calls the imageURLDidChange func
    //changes are saved to Firebase
    @Published var imageURL: URL? {
        didSet {
            imageURLDidChange(from: oldValue)
        }
    }
    @Published var error: Error?
    
    private let authService: AuthService
    
    init(user: User, authService: AuthService) {
        self.name = user.name
        self.imageURL = user.imageURL
        self.authService = authService
    }
    
    func signOut() {
        withStateManagingTask(perform: authService.signOut)
    }
    
    private func imageURLDidChange(from oldValue: URL?) {
        guard imageURL != oldValue else { return }
        withStateManagingTask { [self] in
            try await authService.updateProfileImage(to: imageURL)
        }
    }
}
