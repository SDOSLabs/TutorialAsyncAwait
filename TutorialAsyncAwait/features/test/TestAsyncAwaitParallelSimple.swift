//
//  TestAsyncAwaitParallelSimple.swift
//  TestAsyncAwaitParallelSimple
//
//  Created by Rafael Fernandez Alvarez on 20/9/21.
//

import Foundation

class TestAsyncAwaitParallelSimple: Testable {
    static let shared = TestAsyncAwaitParallelSimple()
    private init() { }
    
    public func start() {
        print("[TestAsyncAwaitParallelSimple] Start")
        Task {
            async let result1 = print1()
            async let result2 = print2()
            await [result1, result2]
        }
    }
    
    private func print1() async {
        for i in 1...10_000 {
            print("[TestAsyncAwaitParallelSimple] - In Task 1: \(i)")
        }
    }
    
    private func print2() async {
        for i in 1...10_000 {
            print("[TestAsyncAwaitParallelSimple] - In Task 2: \(i)")
        }
    }
}
