//
//  TypiCodePostView.swift
//  APIs
//
//  Created by Nikunj  on 10/08/26.
//

import Foundation
import SwiftUI

struct TypiCodePostView: View {
    @State private var title: String = ""
    @State private var postBody: String = ""
    @State private var apiState: APIState = .idle
    
    private var isFormInvalid: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        postBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Create New Post")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $title)
                            .frame(height: 44)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                Text("Enter title for post")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .opacity(title.isEmpty ? 1 : 0),
                                alignment: .topLeading
                            )
                        
                        TextEditor(text: $postBody)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                Text("Enter body for post")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .opacity(postBody.isEmpty ? 1 : 0),
                                alignment: .topLeading
                            )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    Button(action: handlePostSubmit) {
                        HStack {
                            if case .loading = apiState {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                            }
                            Text(caseLoadingTitle)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormInvalid ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isFormInvalid || caseLoadingCheck)
                    
                    statusView
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("TypiCode POST")
        }
    }
    
    private var caseLoadingTitle: String {
        if case .loading = apiState { return "Posting..." }
        return "Submit Post"
    }
    
    private var caseLoadingCheck: Bool {
        if case .loading = apiState { return true }
        return false
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch apiState {
        case .idle:
            EmptyView()
        case .loading:
            EmptyView()
        case .success(let response):
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Post Created Successfully!")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                Divider()
                Text("Assigned ID: \(response.id)")
                    .font(.caption)
                    .bold()
                Text("Title: \(response.title)")
                    .font(.subheadline)
                Text("Body: \(response.body)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.3), lineWidth: 1))
            
        case .failed(let errorMessage):
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Failed to Upload")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
    }
    
    private func handlePostSubmit() {
        apiState = .loading
        
        Task {
            do {
                let response = try await uploadNewPost(title: title, body: postBody)
                await MainActor.run {
                    self.apiState = .success(response)
                    self.title = ""
                    self.postBody = ""
                }
            } catch {
                await MainActor.run {
                    self.apiState = .failed(error.localizedDescription)
                }
            }
        }
    }
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
    case failed(String)
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
