//
//  AuthViewModel.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/23/23.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isUserAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    
    private let authService = AuthService()
    
    init() {
        authService.$isAuthenticated.assign(to: &$isUserAuthenticated)
    }
    
    func signIn() {
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                print("[AuthViewModel] Cannot sign in: \(error)")
            }
        }
    }
}
