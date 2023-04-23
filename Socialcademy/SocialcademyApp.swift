//
//  SocialcademyApp.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/11/23.
//

import SwiftUI
import Firebase

@main
struct SocialcademyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthView()
        }
    }
}
