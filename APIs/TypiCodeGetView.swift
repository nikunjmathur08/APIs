//
//  TypiCodeView.swift
//  APIs
//
//  Created by Nikunj  on 09/08/26.
//

import Foundation
import SwiftUI

struct TypiCodeGetView: View {
    @State private var viewModel = TypiCodeGetViewModel()
    
    var body: some View {
        NavigationStack{
            List(viewModel.posts) { post in
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
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView("Loading posts...")
                } else if let errorMessage = viewModel.errorMessage, viewModel.posts.isEmpty {
                    ContentUnavailableView("Failed to load",
                                           systemImage: "exclamationmark.triangle",
                                           description: Text(errorMessage)
                    )
                }
            }
            .navigationTitle("TypiCode GET API")
            .task {
                await viewModel.loadPosts()
            }
        }
    }
}
