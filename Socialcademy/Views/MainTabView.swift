//
//  MainTabView.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/19/23.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PostsList() //using the default values
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList(viewModel: PostsViewModel(filter: .favorites))
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
