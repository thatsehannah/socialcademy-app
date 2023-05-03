//
//  User.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/30/23.
//

import Foundation

struct User: Identifiable, Equatable, Codable {
    var id: String
    var name: String
}

extension User {
    static let testUser = User(id: "", name: "Jamie Harris")
}
