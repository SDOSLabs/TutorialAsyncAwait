//
//  TestAsyncAwaitCancelation.swift
//  TestAsyncAwaitCancelation
//
//  Created by Rafael Fernandez Alvarez on 21/9/21.
//

import Foundation

class TestAsyncAwaitCancelation: Testable {
    static let shared = TestAsyncAwaitCancelation()
    private init() { }
    
    var firstTask: Task<(), Never>?
    var secondTask: Task<(), Never>?
    
    public func start() {
        print("[TestAsyncAwaitCancelation] Start")
        
        cancelIntData()
        cancelIntDataThrowingError()
        subTasks()
        childTasks()
    }
    
    private func cancelIntData() {
        firstTask = Task {
            let result = await getIntData().map { "\($0)"}.joined(separator: ", ")
            print("[TestAsyncAwaitCancelation] Int Data - Result String: [\(result)]")
        }
        Task {
            await Task.sleep(UInt64.random(in: 4...8) * 1_000_000_000) //Se cancela pasados 2-5 segundos
            firstTask?.cancel()
            print("[TestAsyncAwaitCancelation] Int Data - Cancel!")
        }
    }
    
    private func getIntData() async -> [Int] {
        
        var result: [Int] = []
        for i in 0...10 {
            await Task.sleep(1 * 1_000_000_000) //One seconds
            if Task.isCancelled {
                break
            }
            result.append(i)
            print("[TestAsyncAwaitCancelation] Int Data - Append \(i)")
        }
        return result
    }
    
    //MARK: - Second
    
    private func cancelIntDataThrowingError() {
        secondTask = Task {
            do {
                let result = try await getIntDataThrowingError().map { "\($0)"}.joined(separator: ", ")
                print("[TestAsyncAwaitCancelation] Int Data Throwing Error - Result String: [\(result)]")
            } catch is CancellationError {
                print("[TestAsyncAwaitCancelation] Int Data Throwing Error - Tarea cancelada")
            } catch let error as CancellationError {
                print("[TestAsyncAwaitCancelation] Int Data Throwing Error - Tarea cancelada: \(error)")
            } catch {
                print("[TestAsyncAwaitCancelation] Int Data Throwing Error - Error \(error.localizedDescription)")
            }
        }
        Task {
            await Task.sleep(UInt64.random(in: 4...8) * 1_000_000_000) //Se cancela pasados 2-5 segundos
            secondTask?.cancel()
            print("[TestAsyncAwaitCancelation] Int Data Throwing Error - Cancel!")
        }
    }
    
    private func getIntDataThrowingError() async throws -> [Int] {
        
        var result: [Int] = []
        for i in 0...10 {
            await Task.sleep(1 * 1_000_000_000) //One seconds
            try Task.checkCancellation()
            result.append(i)
            print("[TestAsyncAwaitCancelation] Int Data Throwing Error - Append \(i)")
        }
        return result
    }
    
    enum CustomError: Int, Error {
        case subTasks = 1
        case stringData = 2
    }
    
    private func subTasks() {
        Task {
            Task {
                var result: [Int] = []
                for i in 0...10 {
                    await Task.sleep(1 * 1_000_000_000) //One seconds
                    try Task.checkCancellation()
                    result.append(i)
                    print("[TestAsyncAwaitCancelation] subTasks 1 - Append \(i)")
                }
            }
            Task {
                var result: [Int] = []
                var count = 0
                for i in 0...10 {
                    if count == 5 {
                        throw CustomError.subTasks
                    }
                    await Task.sleep(1 * 1_000_000_000) //One seconds
                    try Task.checkCancellation()
                    result.append(i)
                    print("[TestAsyncAwaitCancelation] subTasks 2 - Append \(i)")
                    count += 1
                }
            }
        }
    }
    
    private func childTasks() {
        Task {
            do {
                var _ = try await getStringDataFirst()
            } catch {
                print("[TestAsyncAwaitCancelation] String Data - Error \(error.localizedDescription)")
            }
        }
    }
    
    
    private func getStringDataFirst() async throws -> [String] {
        var result: [String] = []
        var count = 0
        for i in 0...10 {
            await Task.sleep(1 * 1_000_000_000) //One seconds
            if count == 5 {
                var _ = try await getStringDataSecond()
            }
            try Task.checkCancellation()
            result.append("\(i)")
            print("[TestAsyncAwaitCancelation] String Data - Append \(i)")
            count += 1
        }
        return result
    }
    
    private func getStringDataSecond() async throws -> [String] {
        throw CustomError.stringData
    }
}
