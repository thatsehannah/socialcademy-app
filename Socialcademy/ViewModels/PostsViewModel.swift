//
//  PostsViewModel.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/12/23.
//

import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    enum PostFilter {
        case all, favorites
    }
    
    private let postsRepository: PostsRepositoryProtocol
    private let filter: PostFilter
    
    var title: String {
        switch filter {
        case .all:
            return "All Posts"
        case .favorites:
            return "Favorites"
        }
    }
    
    @Published var loadingState: Loadable<[Post]> = .loading
    
    //gave the the postsRepository and filter parameters default values
    init(postsRepository: PostsRepositoryProtocol = PostsRepository(), filter: PostFilter = .all) {
        self.postsRepository = postsRepository
        self.filter = filter
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
                loadingState = .loaded(try await postsRepository.fetchPosts(matching: filter))
            } catch {
                print("[PostsViewModel] Cannot fetch posts: \(error)")
                loadingState = .error(error)
            }
        }
    }
    
    private func makeDeleteAction(for post: Post) -> () async throws -> Void {
        return { [weak self] in
            try await self?.postsRepository.delete(post)
            self?.loadingState.value?.removeAll { $0.id == post.id }
        }
    }
    
    private func makeFavoriteAction(for post: Post) -> () async throws -> Void {
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
    
    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        return PostRowViewModel(
            post: post,
            deleteAction: makeDeleteAction(for: post),
            favoriteAction: makeFavoriteAction(for: post))
    }
}

private extension PostsRepositoryProtocol {
    func fetchPosts(matching filter: PostsViewModel.PostFilter) async throws -> [Post] {
        switch filter {
        case .all:
            return try await fetchAllPosts()
        case .favorites:
            return try await fetchFavoritedPosts()
        }
    }
}
