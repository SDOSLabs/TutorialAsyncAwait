//
//  TestAsyncAwaitSequence.swift
//  TestAsyncAwaitSequence
//
//  Created by Rafael Fernandez Alvarez on 20/9/21.
//

import Foundation

class TestAsyncAwaitSequence: Testable {
    static let shared = TestAsyncAwaitSequence()
    private init() { }
    
    public func start() {
        print("[TestAsyncAwaitSequence] Start")
        
        Task {
            for await value in NumberGenerator() {
                print("[TestAsyncAwaitSequence] Sequence DoubleGenerator - \(value)")
            }
            try await getURLData()
        }
    }
    
    func getURLData() async throws {
        guard let endpoint = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.csv") else { return }
        
        for try await line in endpoint.lines.dropFirst() {
            let values = line.split(separator: ",")
            let time = values[0]
            let latitude = values[1]
            let longitude = values[2]
            let magnitude = values[3]
            print("[TestAsyncAwaitSequence] CSV - time: \(time), latitude: \(latitude), longitude: \(longitude), magnitude: \(magnitude)")
        }
    }
}


struct NumberGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Int
    var current = 1

    mutating func next() async -> Int? {
        defer { current += 2 }

        await Task.sleep(1 * 1_000_000_000) // Wait one seconds
        if current > 15 {
            return nil
        } else {
            return current
        }
    }

    func makeAsyncIterator() -> NumberGenerator {
        self
    }
}
