//
//  TypiCodeService.swift
//  APIs
//
//  Created by Nikunj  on 16/08/26.
//

import Foundation

struct TypiCodeService {
    func getPosts() async throws -> [Posts] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let posts = try JSONDecoder().decode([Posts].self, from: data)
        return posts
    }
    
    func uploadNewPost(title: String, body: String) async throws -> PostResponse {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        let localPost = PostRequest(title: title, body: body, userId: 1)
        let encodedData = try JSONEncoder().encode(localPost)
        
        request.httpBody = encodedData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(PostResponse.self, from: data)
    }
    
    func putRequest(title: String, body: String) async throws -> PutResponse {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        
        let localPost = PutRequest(id: 1, title: title, body: body, userId: 2)
        let encodedData = try JSONEncoder().encode(localPost)
        
        request.httpBody = encodedData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(PutResponse.self, from: data)
    }
    
    func deletePost(id: Int) async throws -> Bool {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        return true
    }
}
