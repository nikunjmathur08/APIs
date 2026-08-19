//
//  TypiCodeDeleteViewModel.swift
//  APIs
//
//  Created by Nikunj  on 19/08/26.
//

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
public class TypiCodeDeleteViewModel {
    var posts: [Posts] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    private let service = TypiCodeService()
    
    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            posts = try await service.getPosts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func delete(at offsets: IndexSet) async {
        for index in offsets {
            let post = posts[index]
            
            do {
                let deleted = try await service.deletePost(id: post.id)
                
                if deleted {
                    withAnimation {
                        posts.removeAll { $0.id == post.id }
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
