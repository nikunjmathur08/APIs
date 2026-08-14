//
//  TypiCodePutView.swift
//  APIs
//
//  Created by Nikunj  on 11/08/26.
//

import Foundation
import SwiftUI

struct TypiCodePutView: View {
    @State private var title: String = ""
    @State private var putBody: String = ""
    @State private var isLoading: Bool = false
    @State private var putResponse: PutResponse? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Update Post Details")) {
                    TextField("Title", text:$title)
                        .textInputAutocapitalization(.sentences)
                    
                    TextField("Body", text:$putBody)
                        .textInputAutocapitalization(.sentences)
                }
                
                Section {
                    Button(action: handleSubmission) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Submit Update")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || putBody.isEmpty || isLoading)
                    .listRowBackground(title.isEmpty || putBody.isEmpty ? Color.gray.opacity(0.3) : Color.accentColor)
                    .foregroundStyle(.white)
                }
                
                if let response = putResponse {
                    Section(header: Text("Server Response")) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Post ID: \(response.id)")
                                Spacer()
                                Text("User ID: \(response.userId)")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            
                            Divider()
                            
                            Text(response.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text(response.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Update Post")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func handleSubmission() {
        Task {
            do {
                isLoading = true
                putResponse = try await putRequest(title: title, body: putBody)
            } catch {
                print("Failed to make API call: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
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
