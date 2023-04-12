//
//  PostsList.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/11/23.
//

import SwiftUI

struct PostsList: View {
    private var posts: [Post] = [Post.testPost]
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(posts.filter {searchText.isEmpty || $0.contains(searchText)} ) { post in
                    PostRow(post: post)
                }
            }
            .navigationTitle("Posts")
            .searchable(text: $searchText)
        }
        
        
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
    }
}
