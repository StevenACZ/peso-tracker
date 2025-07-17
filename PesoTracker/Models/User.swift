//
//  User.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
}