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
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func makePostsViewModel(filter: PostsViewModel.PostFilter = .all) -> PostsViewModel {
        return PostsViewModel(postsRepository: PostsRepository(currentUser: currentUser), filter: filter)
    }
    
    func makeCommentsViewModel(for post: Post) -> CommentsViewModel {
        return CommentsViewModel(commentsRepository: CommentsRepository(user: currentUser, post: post))
    }
}

#if DEBUG
extension ViewModelFactory {
    static let preview = ViewModelFactory(currentUser: User.testUser)
}
#endif
