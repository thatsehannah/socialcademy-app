//
//  PostsViewModel.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/12/23.
//

import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    @Published var loadingState: Loadable<[Post]> = .loading
    
    func makeCreateAction() -> NewPostForm.CreateAction {
        return { [weak self] post in
            try await PostsRepository.create(post)
            self?.loadingState.value?.insert(post, at: 0)
        }
    }
    
    func fetchPosts() {
        Task {
            do {
                loadingState = .loaded(try await PostsRepository.fetchPosts())
            } catch {
                print("[PostsViewModel] Cannot fetch posts: \(error)")
                loadingState = .error(error)
            }
        }
    }
}
