//
//  TestAsyncAwaitSyntax.swift
//  TestAsyncAwaitSyntax
//
//  Created by Rafael Fernandez Alvarez on 20/9/21.
//

import Foundation

class TestAsyncAwaitSyntax: Testable {
    static let shared = TestAsyncAwaitSyntax()
    private init() { }
    
    public func start() {
        print("[TestAsyncAwaitSyntax] Start")
        Task {
            await getIntData().forEach { print("[TestAsyncAwaitSyntax] Int Data - \($0)") }
        }
    }
    
    @available(*, deprecated, message: "Prefer async alternative instead")
    private func getIntData(completion: @escaping ([Int]) -> Void) {
        Task {
            let result = await getIntData()
            completion(result)
        }
    }
    
    
    private func getIntData() async -> [Int] {
        //Do something async here, for example url request
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    }
    
}
