//
//  ContentView.swift
//  APIs
//
//  Created by Nikunj  on 08/08/26.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var characters: [APICharacter] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var currentPage = 1
    @State private var totalPages = 1
    
    var body: some View {
        NavigationStack {
            List(characters) { character in
                HStack(alignment: .top, spacing: 16) {
                    AsyncImage(url: URL(string: character.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            Image(systemName: "person.fill")
                                .font(.title)
                                .frame(width: 100, height: 100)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(character.name)
                            .font(.headline)
                        
                        Text("Gender: \(character.gender)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Location: \(character.location.name)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
            .overlay {
                if isLoading && characters.isEmpty {
                    ProgressView("Loading characters...")
                } else if let errorMessage, characters.isEmpty {
                    ContentUnavailableView("Failed to load", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                }
            }
            .refreshable {
                await loadCharacters(page: currentPage, showsLoadingIndicator: false)
            }
            .navigationTitle("Rick & Morty!")
            .safeAreaInset(edge: .bottom) {
                pageControls
            }
            .task {
                await loadCharacters(page: currentPage)
            }
        }
    }
    
    private var pageControls: some View {
        HStack {
            Button {
                Task {
                    await loadCharacters(page: currentPage - 1) }
            } label: {
                Image(systemName: "chevron.left")
                    .bold()
                    .padding()
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.4), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            }
            .disabled(isLoading || currentPage <= 1)
            
            Spacer()
            
            Text("Page \(currentPage) of \(totalPages)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.4), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            Spacer()
            
            Button {
                Task {
                    await loadCharacters(page: currentPage + 1) }
            } label: {
                Image(systemName: "chevron.right")
                    .bold()
                    .padding()
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.4), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            }
            .disabled(isLoading || currentPage >= totalPages)
            .opacity(currentPage >= totalPages ? 0.4 : 1.0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
    
    private func loadCharacters(page: Int, showsLoadingIndicator: Bool = true) async {
        guard page >= 1 else { return }
        
        if showsLoadingIndicator {
            isLoading = true
        }
        
        do {
            let response = try await fetchCharacterResponse(page: page)
            characters = response.results
            currentPage = page
            totalPages = response.info.pages
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("API Fetch failed: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    ContentView()
}

struct CharacterResponse: Codable {
    let info: Info
    let results: [APICharacter]
}

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let previous: String?
}

struct APICharacter: Codable, Identifiable {
    let id: Int
    let name: String
    let gender: String
    let location: Location
    let image: String
}

struct Location: Codable {
    let name: String
    let url: String
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
}

func fetchCharacterResponse(page: Int) async throws -> CharacterResponse {
    guard let url = URL(string: "https://rickandmortyapi.com/api/character/?page=\(page)") else {
        throw NetworkError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.invalidResponse
    }
    
    return try JSONDecoder().decode(CharacterResponse.self, from: data)
}

func fetchCharacters(page: Int) async throws -> [APICharacter] {
    let apiResponse = try await fetchCharacterResponse(page: page)
    return apiResponse.results
}
