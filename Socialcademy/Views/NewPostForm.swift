//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/12/23.
//

import SwiftUI

struct NewPostForm: View {
    typealias CreateAction = (Post) async throws -> Void
    let createAction: CreateAction
    
    @State private var post = Post(title: "", content: "", authorName: "" )
    @State private var state = FormState.idle
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $post.title)
                    TextField("Author", text: $post.authorName)
                }
                Section("Content") {
                    TextEditor(text: $post.content)
                        .multilineTextAlignment(.leading)
                }
                Button(action: createPost) {
                    if state == .working {
                        ProgressView()
                    } else {
                        Text("Create Post")
                    }
                }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .listRowBackground(Color.accentColor)
            }
            .onSubmit(createPost)
            .navigationTitle("New Post")
        }
        .disabled(state == .working)
        .alert("Cannot create post", isPresented: $state.isError) {
            Text("Sorry, something went wrong.")
        }
    }
    
    private func createPost() {
        Task {
            state = .working
            do {
                try await createAction(post)
                dismiss()
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
                state = .error
            }
        }
    }
}

private extension NewPostForm {
    enum FormState {
        case idle, working, error
        
        //set to true when the current FormState is error
        //Declared both a getter and a setter because this is required to create a two-way binding
        //When the user dismisses the alaert, SwiftUI will set isError to false, causing the FormState
        //to revert to idle
        var isError: Bool {
            get {
                self == .error
            }
            set {
                guard !newValue else { return }
                self = .idle
            }
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(createAction: { _ in })
    }
}
