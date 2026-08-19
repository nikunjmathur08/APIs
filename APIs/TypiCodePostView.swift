//
//  TypiCodePostView.swift
//  APIs
//
//  Created by Nikunj  on 10/08/26.
//

import Foundation
import SwiftUI

struct TypiCodePostView: View {
    @State private var viewModel = TypiCodePostViewModel()
    
    
    private var isFormInvalid: Bool {
        viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        viewModel.postBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Create New Post")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $viewModel.title)
                            .frame(height: 44)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                Text("Enter title for post")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .opacity(viewModel.title.isEmpty ? 1 : 0),
                                alignment: .topLeading
                            )
                        
                        TextEditor(text: $viewModel.postBody)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                Text("Enter body for post")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .opacity(viewModel.postBody.isEmpty ? 1 : 0),
                                alignment: .topLeading
                            )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    Button(action: handlePostSubmit) {
                        HStack {
                            if case .loading = viewModel.apiState {
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
        if case .loading = viewModel.apiState { return "Posting..." }
        return "Submit Post"
    }
    
    private var caseLoadingCheck: Bool {
        if case .loading = viewModel.apiState { return true }
        return false
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch viewModel.apiState {
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
            
        case .failure(let errorMessage):
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
        Task {
            await viewModel.submit()
        }
    }
}
