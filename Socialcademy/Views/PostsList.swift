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
            List {
                ForEach(viewModel.posts.filter {searchText.isEmpty || $0.contains(searchText)} ) { post in
                    PostRow(post: post)
                }
            }
            .navigationTitle("Posts")
            .searchable(text: $searchText)
            .toolbar {
                Button {
                    showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showNewPostForm) {
            NewPostForm(createAction: viewModel.makeCreateAction())
        }
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
    }
}
