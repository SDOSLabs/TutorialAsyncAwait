//
//  TestAsyncAwait.swift
//  TestAsyncAwait
//
//  Created by Rafael Fernandez Alvarez on 16/9/21.
//

import Foundation

protocol Testable {
    func start()
}

class TestAsyncAwait {
    static let shared = TestAsyncAwait()
    private init() { }
    
    var task: Task<(), Error>?
    
    public func start() {
        TestAsyncAwaitSyntax.shared.start()
        TestAsyncAwaitParallelSimple.shared.start()
        TestAsyncAwaitParallelImage.shared.start()
        TestAsyncAwaitSequence.shared.start()
        TestAsyncAwaitTasks.shared.start()
        TestAsyncAwaitCancelation.shared.start()
        TestAsyncAwaitContinuation.shared.start()
    }
    
}
