//
//  PostsList.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/11/23.
//

import SwiftUI

struct PostsList: View {
    @StateObject var viewModel: PostsViewModel
    @State private var searchText = ""
    @State private var showNewPostForm = false
    
    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loading:
                ProgressView()
            case .error(let error):
                EmptyListView(
                    title: "Cannot Load Posts",
                    message: error.localizedDescription,
                    retryAction: {
                        viewModel.fetchPosts()
                    }
                )
            case .empty:
                EmptyListView(
                    title: "No Posts",
                    message: "There aren't any posts yet."
                )
            case let .loaded(posts):
                ScrollView {
                    ForEach(posts) { post in
                        if searchText.isEmpty || post.contains(searchText) {
                            PostRow(viewModel: viewModel.makePostRowViewModel(for: post))
                        }
                    }
                }
                .searchable(text: $searchText)
                .animation(.default, value: posts)
            }
            
        }
        .onAppear {
            viewModel.fetchPosts()
        }
        .navigationTitle(viewModel.title)
        .toolbar {
            Button {
                showNewPostForm = true
            } label: {
                Label("New Post", systemImage: "square.and.pencil")
            }
        }
        .sheet(isPresented: $showNewPostForm) {
            NewPostForm(viewModel: viewModel.makeNewPostViewModel())
        }
    }
        
}



#if DEBUG
struct PostsList_Previews: PreviewProvider {
    @MainActor
    private struct ListPreview: View {
        let state: Loadable<[Post]>
        
        var body: some View {
            let postsRepository = PostsRepositoryStub(state: state)
            let viewModel = PostsViewModel(postsRepository: postsRepository)
            NavigationView {
                PostsList(viewModel: viewModel).environmentObject(ViewModelFactory.preview)
            }
            
        }
    }
    
    static var previews: some View {
        ListPreview(state: .loaded([Post.testPost]))
        ListPreview(state: .empty)
        ListPreview(state: .error)
        ListPreview(state: .loading)
    }
}
#endif
