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
    init(postsRepository: PostsRepositoryProtocol, filter: PostFilter = .all) {
        self.postsRepository = postsRepository
        self.filter = filter
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
    
    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        let deleteAction = { [weak self] in
            try await self?.postsRepository.delete(post)
            self?.loadingState.value?.removeAll { $0 == post}
        }
        
        let favoriteAction = { [weak self] in
            let newValue = !post.isFavorite
            try await newValue ? self?.postsRepository.favorite(post) : self?.postsRepository.unfavorite(post)
            guard let i = self?.loadingState.value?.firstIndex(of: post) else { return }
            self?.loadingState.value?[i].isFavorite = newValue
        }
        
        return PostRowViewModel(
            post: post,
            deleteAction: postsRepository.canDelete(post) ? deleteAction : nil,
            favoriteAction: favoriteAction)
    }
    
    func makeNewPostViewModel() -> FormViewModel<Post> {
        return FormViewModel(initialValue: Post(title: "", content: "", author: postsRepository.currentUser), action: { [weak self] post in
            try await self?.postsRepository.create(post)
            self?.loadingState.value?.insert(post, at: 0)
        })
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
