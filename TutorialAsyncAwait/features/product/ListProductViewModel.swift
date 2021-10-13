//
//  ContentViewModel.swift
//  ContentViewModel
//
//  Created by Rafael Fernandez Alvarez on 20/9/21.
//

import Foundation
import SwiftUI

enum ListProductViewState {
    case idle
    case loading
    case error(Error)
    case loaded([ProductDTO])
}

@MainActor
class ListProductViewModel: ObservableObject {
    @Published var state: ListProductViewState = .idle
    
    func loadData() async {
        guard let url = URL(string: "https://raw.githubusercontent.com/SDOSLabs/JSON-Sample/master/Products/products.json") else { return }
        
        do {
            state = .loading
            await Task.sleep(5 * 1_000_000_000) // Wait five seconds
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode([ProductDTO].self, from: data)
            state = .loaded(result)
        } catch {
            state = .error(error)
        }
    }
}
