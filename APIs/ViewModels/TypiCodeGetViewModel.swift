//
//  TypiCodeGetViewModel.swift
//  APIs
//
//  Created by Nikunj  on 16/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
class TypiCodeGetViewModel {
    var posts: [Posts] = []
    var isLoading = true
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
}
