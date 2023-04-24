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
            NavigationView {
                SignInForm(viewModel: viewModel.makeSignInViewModel()) {
                    NavigationLink("Create Account") {
                        CreateAccountForm(viewModel: viewModel.makeCreateAccountViewModel())
                    }
                }
            }
        }
    }
}

//generic form to be used for auth forms
private extension AuthView {
    struct AuthForm<Content: View, Footer: View>: View {
        @ViewBuilder let content: () -> Content
        @ViewBuilder let footer: () -> Footer
        
        var body: some View {
            VStack {
                Text("Socialcademy")
                    .font(.title.bold())
                content()
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(10)
                footer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

//sign in form
private extension AuthView {
    struct SignInForm<Footer: View>: View {
        @StateObject var viewModel: AuthViewModel.SignInViewModel
        @ViewBuilder let footer: () -> Footer //closure that returns a view
        
        var body: some View {
            AuthForm {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            } footer: {
                Button("Sign In", action: viewModel.submit)
                    .buttonStyle(.primary)
                footer()
                    .padding()
            }
            .onSubmit(viewModel.submit)
            .alert("Cannot Sign In", error: $viewModel.error)
        }
    }
}

//create account form
private extension AuthView {
    struct CreateAccountForm: View {
        @Environment(\.dismiss) private var dismiss
        @StateObject var viewModel: AuthViewModel.CreateAccountViewModel
        
        var body: some View {
            AuthForm {
                TextField("Name", text: $viewModel.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
            } footer: {
                Button("Create Account", action: viewModel.submit)
                    .buttonStyle(.primary)
                Button("Sign In", action: dismiss.callAsFunction)
                    .padding()
            }
            .onSubmit(viewModel.submit)
            .alert("Cannot Create Account", error: $viewModel.error)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
