//
//  PostsViewModel.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/12/23.
//

import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    private let postsRepository: PostsRepositoryProtocol
    @Published var loadingState: Loadable<[Post]> = .loading
    
    init(postsRepository: PostsRepositoryProtocol = PostsRepository()) {
        self.postsRepository = postsRepository
    }
    
    func makeCreateAction() -> NewPostForm.CreateAction {
        return { [weak self] post in
            try await self?.postsRepository.create(post)
            self?.loadingState.value?.insert(post, at: 0)
        }
    }
    
    func fetchPosts() {
        Task {
            do {
                loadingState = .loaded(try await postsRepository.fetchPosts())
            } catch {
                print("[PostsViewModel] Cannot fetch posts: \(error)")
                loadingState = .error(error)
            }
        }
    }
    
    func makeDeleteAction(for post: Post) -> PostRow.Action {
        return { [weak self] in
            try await self?.postsRepository.delete(post)
            self?.loadingState.value?.removeAll { $0.id == post.id }
        }
    }
    
    func makeFavoriteAction(for post: Post) -> () async throws -> Void {
        return { [weak self] in
            //determines the new value of isFavorite, which is the opposite of its former value
            let newValue = !post.isFavorite
            
            //calls the favorite method if newValue is true or the unfavorite method otherwise
            try await newValue ? self?.postsRepository.favorite(post) : self?.postsRepository.unfavorite(post)
            
            //finds the post's index in the PostList
            guard let index = self?.loadingState.value?.firstIndex(of: post) else {
                return
            }
            
            //sets the post's isFavorite property to newValue
            self?.loadingState.value?[index].isFavorite = newValue
        }
        
    }
}
