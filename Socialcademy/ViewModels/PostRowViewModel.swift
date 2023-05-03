//
//  PostRowViewModel.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/18/23.
//

import Foundation

@MainActor
@dynamicMemberLookup //allows us to reference Post properties as if they're properties of this view model
class PostRowViewModel: ObservableObject {
    typealias Action = () async throws -> Void
    
    @Published var post: Post
    @Published var error: Error?
    
    private let deleteAction: Action?
    private let favoriteAction: Action
    var canDeletePost: Bool {
        deleteAction != nil
    }
    
    init(post: Post, deleteAction: Action?, favoriteAction: @escaping Action) {
        self.post = post
        self.deleteAction = deleteAction
        self.favoriteAction = favoriteAction
    }
    
    //Swift will call this method whenever we access a dynamic member
    //Method takes a key path, which lets us reference any property of the Post model
    //using the post property of the PostRowVieModel, it returns the value of the requested property
    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }
    
    private func performAction(_ action: @escaping Action) {
        Task {
            do {
                try await action()
            } catch {
                print("[PostRowViewModel] Error: \(error)")
                self.error = error
            }
        }
    }
    
    func deletePost() {
        guard let deleteAction = deleteAction else {
            preconditionFailure("Cannot delete post: no delete action provided")
        }
        
        performAction(deleteAction)
    }
    
    func favoritePost() {
        performAction(favoriteAction)
    }
}
