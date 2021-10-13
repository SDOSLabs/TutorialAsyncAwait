//
//  TestAsyncAwaitActor.swift
//  TutorialAsyncAwait
//
//  Created by Rafael Fernandez Alvarez on 28/9/21.
//

import Foundation

class TestAsyncAwaitActor: Testable {
    static let shared = TestAsyncAwaitActor()
    private init() { }
    
    func start() {
//        dataRaceSample()
        dataRaceFixSample()
        Task {
            await debugLog(dataStore: DataStore())
        }
        
    }
    
    func dataRaceSample() {
        let user = UserData()
        
        DispatchQueue.init(label: "First Thread", qos: .utility).async {
            defer { print("[TestAsyncAwaitActor] dataRaceSample - First Thread - Finish") }
            for count in 0...10_000 {
                let newID = Int.random(in: 0...100)
                print("[TestAsyncAwaitActor] dataRaceSample - First Thread - Loop \(count), Change \(newID) from old value \(user.id)")
                user.changeID(id: newID)
            }
        }
        
        DispatchQueue.init(label: "Second Thread", qos: .background).async {
            defer { print("[TestAsyncAwaitActor] dataRaceSample - Second Thread - Finish") }
            for count in 0...10_000 {
                let newID = Int.random(in: 0...100)
                print("[TestAsyncAwaitActor] dataRaceSample - Second Thread - Loop \(count), Change \(newID) from old value \(user.id)")
                user.changeID(id: newID)
            }
        }
    }
    
    func dataRaceFixSample() {
        let user = UserDataActor()
        Task {
            async let task1 = Task.detached {
                defer { print("[TestAsyncAwaitActor] dataRaceFixSample - First Task - Finish") }
                for count in 0...10_000 {
                    let newID = Int.random(in: 0...100)
                    print("[TestAsyncAwaitActor] dataRaceFixSample - First Task - Loop \(count), Change \(newID) from old value \(await user.id)")
                    await user.changeID(id: newID)
                }
            }
            
            async let task2 = Task.detached {
                defer { print("[TestAsyncAwaitActor] dataRaceFixSample - Second Task - Finish") }
                for count in 0...10_000 {
                    let newID = Int.random(in: 0...100)
                    print("[TestAsyncAwaitActor] dataRaceFixSample - Second Task - Loop \(count), Change \(newID) from old value \(await user.id)")
                    await user.changeID(id: newID)
                }
            }
            
            await [task1, task2]
        }
    }
    
    func debugLog(dataStore: isolated DataStore) {
        print("[TestAsyncAwaitActor] debugLog - Username: \(dataStore.username)")
        print("[TestAsyncAwaitActor] debugLog - Friends: \(dataStore.friends)")
        print("[TestAsyncAwaitActor] debugLog - High scores: \(dataStore.highScores)")
        print("[TestAsyncAwaitActor] debugLog - Favorites: \(dataStore.favorites)")
    }
    
}

class UserData {
    var id: Int = 0
    private var history: [Int] = [0]
    
    func changeID(id: Int) {
        self.id = id
        history.append(id)
    }
}

actor UserDataActor {
    var id: Int = 0
    private var history: [Int] = [0]
    
    func changeID(id: Int) {
        self.id = id
        history.append(id)
    }
}

actor DataStore {
    var username = "Anonymous"
    var friends = [String]()
    var highScores = [Int]()
    var favorites = Set<Int>()
}
