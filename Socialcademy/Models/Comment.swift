//
//  Comment.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 5/5/23.
//

import Foundation

struct Comment: Identifiable, Equatable, Codable {
    var id = UUID()
    var content: String
    var author: User
    var timestamp = Date()
}

extension Comment {
    static let testComment = Comment(content: "Hey look, it's a comment.", author: User.testUser)
}
