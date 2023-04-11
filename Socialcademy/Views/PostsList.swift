//
//  PostsList.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/11/23.
//

import SwiftUI

struct PostsList: View {
    private var posts: [Post] = [Post.testPost]
    var body: some View {
        NavigationView {
            List(posts) { post in
                Text(post.content)
            }
            .navigationTitle("Posts")
        }
        
        
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
    }
}
