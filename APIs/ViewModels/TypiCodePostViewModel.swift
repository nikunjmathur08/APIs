//
//  TypiCodePostViewModel.swift
//  APIs
//
//  Created by Nikunj  on 19/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
public class TypiCodePostViewModel {
    var title: String = ""
    var postBody: String = ""
    var apiState: APIState = .idle
    
    private let service = TypiCodeService()
    
    func submit() async {
        apiState = .loading
        
        do {
            let response = try await service.uploadNewPost(title: title, body: postBody)
            apiState = .success(response)
        } catch {
            apiState = .failure(error.localizedDescription)
        }
    }
}
