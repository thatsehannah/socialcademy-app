//
//  ViewModelFactory.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 5/3/23.
//

import Foundation

@MainActor
class ViewModelFactory: ObservableObject {
    private let currentUser: User
    private let authService: AuthService
    
    init(currentUser: User, authService: AuthService) {
        self.currentUser = currentUser
        self.authService = authService
    }
    
    func makePostsViewModel(filter: PostsViewModel.PostFilter = .all) -> PostsViewModel {
        return PostsViewModel(postsRepository: PostsRepository(currentUser: currentUser), filter: filter)
    }
    
    func makeCommentsViewModel(for post: Post) -> CommentsViewModel {
        return CommentsViewModel(commentsRepository: CommentsRepository(user: currentUser, post: post))
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(user: currentUser, authService: authService)
    }
}

#if DEBUG
extension ViewModelFactory {
    static let preview = ViewModelFactory(currentUser: User.testUser, authService: AuthService())
}
#endif
