//
//  Posts.swift
//  APIs
//
//  Created by Nikunj  on 16/08/26.
//

import Foundation

struct Posts: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct PostRequest: Codable {
    let title: String
    let body: String
    let userId: Int
}

struct PostResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

enum APIState {
    case idle
    case loading
    case success(PostResponse)
    case failure(String)
}

struct PutRequest: Codable {
    var id: Int
    var title: String
    var body: String
    var userId: Int
}

struct PutResponse: Codable, Identifiable {
    var id: Int
    var title: String
    var body: String
    var userId: Int
}
