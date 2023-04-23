//
//  ProfileView.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/23/23.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    var body: some View {
        Button("Sign Out") {
            try! Auth.auth().signOut()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
