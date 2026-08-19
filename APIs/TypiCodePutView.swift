//
//  TypiCodePutView.swift
//  APIs
//
//  Created by Nikunj  on 11/08/26.
//

import Foundation
import SwiftUI

struct TypiCodePutView: View {
    @State private var viewModel = TypiCodePutViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Update Post Details")) {
                    TextField("Title", text:$viewModel.title)
                        .textInputAutocapitalization(.sentences)
                    
                    TextField("Body", text:$viewModel.putBody)
                        .textInputAutocapitalization(.sentences)
                }
                
                Section {
                    Button(action: handleSubmission) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Submit Update")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.putBody.isEmpty || viewModel.isLoading)
                    .listRowBackground(viewModel.title.isEmpty || viewModel.putBody.isEmpty ? Color.gray.opacity(0.3) : Color.accentColor)
                    .foregroundStyle(.white)
                }
                
                if let response = viewModel.putResponse {
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
            await viewModel.submit()
        }
    }
}
