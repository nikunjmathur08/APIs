//
//  TypiCodeView.swift
//  APIs
//
//  Created by Nikunj  on 09/08/26.
//

import Foundation
import SwiftUI

struct TypiCodeGetView: View {
    @State private var posts: [Posts] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    
    var body: some View {
        NavigationStack{
            List(posts) { post in
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.title)
                            .font(.headline)
                        
                        Text(post.body)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 4)
            }
            .overlay {
                if isLoading && posts.isEmpty {
                    ProgressView("Loading posts...")
                } else if let errorMessage, posts.isEmpty {
                    ContentUnavailableView("Failed to load",
                                           systemImage: "exclamationmark.triangle",
                                           description: Text(errorMessage)
                    )
                }
            }
            .navigationTitle("TypiCode GET API")
            .task {
                do {
                    let response = try await getPosts()
                    posts = response
                    errorMessage = nil
                } catch {
                    errorMessage = error.localizedDescription
                    print("API Call failed: \(error.localizedDescription)")
                }
                isLoading = false
            }
        }
    }
}

struct Posts: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

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
