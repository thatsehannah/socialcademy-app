//
//  FormViewModel.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/23/23.
//

import Foundation

//View model that collects and submits information from forms
//Uses a generic Value type to specify the information collected and provide an action for submitting that information
@MainActor
@dynamicMemberLookup
class FormViewModel<Value>: ObservableObject {
    typealias Action = (Value) async throws -> Void
    
    @Published var value: Value
    @Published var error: Error?
    @Published var isWorking = false
    private let action: Action
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get {value[keyPath: keyPath]}
        set {value[keyPath: keyPath] = newValue}
    }
    
    init(initialValue: Value, action: @escaping Action) {
        self.value = initialValue
        self.action = action
    }
    
    private func handleSubmit() async {
        isWorking = true
        do {
            try await action(value)
        } catch {
            print("[FormViewModel] Cannot submit: \(error)")
            self.error = error
        }
        isWorking = false
    }
    
    nonisolated func submit() {
        Task {
            await handleSubmit()
        }
    }
}
