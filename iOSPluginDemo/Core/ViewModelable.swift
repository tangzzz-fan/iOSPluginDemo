//
//  ViewModelable.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import Foundation
import Combine
import SwiftyBeaver

// MARK: - View Model Protocol
protocol ViewModelable: ObservableObject {
    var cancellables: Set<AnyCancellable> { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    
    func setupBindings()
    func handleError(_ error: Error)
    func clearError()
    func setLoading(_ loading: Bool)
}

// MARK: - View Model State Management

enum ViewModelState {
    case idle
    case loading
    case loaded
    case error(Error)
}

// MARK: - View Model Error Handling
protocol ViewModelErrorHandling {
    func handleError(_ error: Error)
    func clearError()
}

// MARK: - Default Implementation
extension ViewModelable {
    func setupBindings() {
        // Override in conforming types
    }
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        log.error("Error occurred: \(error)")
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    // MARK: - Logging
    var log: SwiftyBeaver.Type {
        return SwiftyBeaver.self
    }
} 
