//
//  TypiCodeDelete.swift
//  APIs
//
//  Created by Nikunj  on 16/08/26.
//

import Foundation
import SwiftUI

struct TypiCodeDelete : View {
    @State private var posts: [Posts] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading && posts.isEmpty {
                    ProgressView("Loading items...")
                } else if let errorMessage, posts.isEmpty {
                    ContentUnavailableView("Failed to load posts", systemImage: "wifi.slash", description: Text(errorMessage))
                } else {
                    List {
                        Section(header: Text("Swipe left to delete a post")) {
                            ForEach(posts) { post in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.title)
                                        .font(.headline)
                                    
                                    Text(post.body)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete { indexSet in
                                handleDeleteGesture(at: indexSet)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Delete Post")
        .task {
            await loadPosts()
        }
    }
    
    private func loadPosts() async {
        do {
            let fetchedPosts = try await getPosts()
            self.posts = fetchedPosts
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    private func handleDeleteGesture(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let targetPost = posts[index]
        
        Task {
            do {
                let success = try await deletePost(id: targetPost.id)
                if success {
                    withAnimation {
                        posts.removeAll { $0.id == targetPost.id }
                    }
                    print("Successfully deleted item with ID: \(targetPost.id)")
                }
            } catch {
                print("Failed to execute delete: \(error.localizedDescription)")
            }
        }
    }
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
