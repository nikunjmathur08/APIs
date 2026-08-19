//
//  TypiCodePutViewModel.swift
//  APIs
//
//  Created by Nikunj  on 19/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
public class TypiCodePutViewModel {
    var title = ""
    var putBody = ""
    var isLoading = false
    var putResponse: PutResponse? = nil
    var errorMessage: String? = nil
    
    private let service = TypiCodeService()
    
    func submit() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            putResponse = try await service.putRequest(title: title, body: putBody)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
