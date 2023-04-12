//
//  PostsList.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/11/23.
//

import SwiftUI

struct PostsList: View {
    @StateObject var viewModel = PostsViewModel()
    @State private var searchText = ""
    @State private var showNewPostForm = false
    
    var body: some View {
        NavigationView {
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
                    List {
                        ForEach(posts.filter {searchText.isEmpty || $0.contains(searchText)} ) { post in
                            PostRow(post: post)
                        }
                    }
                    .searchable(text: $searchText)
                }
                
            }
            .navigationTitle("Posts")
            .toolbar {
                Button {
                    showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            }
            .sheet(isPresented: $showNewPostForm) {
                NewPostForm(createAction: viewModel.makeCreateAction())
            }
        }
        .onAppear {
            viewModel.fetchPosts()
        }
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
    }
}
