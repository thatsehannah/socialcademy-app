//
//  AuthView.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/23/23.
//

import SwiftUI

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        if viewModel.isUserAuthenticated {
            MainTabView()
        } else {
            Form {
                TextField("Email", text: $viewModel.email)
                SecureField("Password", text: $viewModel.password)
                Button("Sign In") {
                    viewModel.signIn()
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
