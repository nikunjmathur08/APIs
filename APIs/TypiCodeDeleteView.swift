//
//  TypiCodeDeleteView.swift
//  APIs
//
//  Created by Nikunj  on 16/08/26.
//

import Foundation
import SwiftUI

struct TypiCodeDeleteView : View {
    @State private var viewModel = TypiCodeDeleteViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView("Loading items...")
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.posts.isEmpty {
                    ContentUnavailableView("Failed to load posts", systemImage: "wifi.slash", description: Text(errorMessage))
                } else {
                    List {
                        Section(header: Text("Swipe left to delete a post")) {
                            ForEach(viewModel.posts) { post in
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
                            .onDelete { offsets in
                                Task {
                                    await viewModel.delete(at: offsets)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Delete Post")
        .task {
            await viewModel.loadPosts()
        }
    }
}
