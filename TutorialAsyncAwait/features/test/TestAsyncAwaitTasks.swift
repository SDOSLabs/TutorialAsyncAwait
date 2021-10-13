//
//  TestAsyncAwaitTasks.swift
//  TestAsyncAwaitTasks
//
//  Created by Rafael Fernandez Alvarez on 20/9/21.
//

import Foundation

class TestAsyncAwaitTasks: Testable {
    static let shared = TestAsyncAwaitTasks()
    private init() { }
    
    public func start() {
        print("[TestAsyncAwaitTasks] Start")
        
        Task {
            await doWorkSync()
            await doWorkDetached()
            await taskWithValue()
            await taskGroup()
            await throwingTaskGroup()
        }
    }
    
    // MARK:  - First
    
    @MainActor
    func doWorkSync() {
        Task {
            for i in 1...10_000 {
                print("[TestAsyncAwaitTasks] Task Sync - In Task 1: \(i)")
            }
        }
        
        Task {
            for i in 1...10_000 {
                print("[TestAsyncAwaitTasks] Task Sync - In Task 2: \(i)")
            }
        }
    }
    
    @MainActor
    func doWorkDetached() {
        Task.detached {
            for i in 1...10_000 {
                print("[TestAsyncAwaitTasks] Task Detached - In Task 1: \(i)")
            }
        }
        
        Task.detached {
            for i in 1...10_000 {
                print("[TestAsyncAwaitTasks] Task Detached - In Task 2: \(i)")
            }
        }
    }
    
    // MARK: - Second
    
    func taskWithValue() async {
        do {
            let result = try await Task<Int, Never> {
                var value = 0
                for i in 1...10 { //Esto da 55
                    value += i
                }
                return value
            }.result.get()
            print("[TestAsyncAwaitTasks] Task With Value: \(result)")
        } catch {
            //Nunca ocurre
        }
    }
    
    // MARK: - Third
    
    private func taskGroup() async {
        var results: [Int] = []
        await withTaskGroup(of: [Int].self) { taskGroup in
            taskGroup.addTask {
                return await self.randomInt(range: 100...199)
            }
            taskGroup.addTask {
                return await self.randomInt(range: 200...299)
            }
            for await partialResult in taskGroup {
                results.append(contentsOf: partialResult)
            }
        }
        
        results.forEach { print("[TestAsyncAwaitTasks] Task Group - Value: \($0)")}
    }
    
    private func randomInt(range: ClosedRange<Int>) async -> [Int] {
        await Task.sleep(1 * 1_000_000_000)  // Wait one second
        var results: [Int] = []
        for _ in 0...4 {
            results.append(Int.random(in: range))
        }
        return results
    }
    
    
    enum CustomError: Int, Error {
        case throwingTaskGroupError = 1
    }
    
    private func throwingTaskGroup() async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    for i in 1...10_000 {
                        try Task.checkCancellation() //Si quitamos esto la ejecución no se parará aunque haya ocurrido un error
                        print("[TestAsyncAwaitTasks] Throwing Task Group - In Task 1: \(i)")
                    }
                }
                
                taskGroup.addTask {
                    var count = 0
                    for i in 1...10_000 {
                        try Task.checkCancellation() //Si quitamos esto la ejecución no se parará aunque haya ocurrido un error
                        print("[TestAsyncAwaitTasks] Throwing Task Group - In Task 2: \(i)")
                        count += 1
                        if count == 5_000 {
                            throw CustomError.throwingTaskGroupError
                        }
                    }
                }
                
                try await taskGroup.waitForAll()
            }
        } catch {
            print("[TestAsyncAwaitTasks] Throwing Task Group - Error: \(error)")
        }
    }
    
}
