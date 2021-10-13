//
//  TestAsyncAwaitParallelImage.swift
//  TestAsyncAwaitParallelImage
//
//  Created by Rafael Fernandez Alvarez on 20/9/21.
//

import Foundation
import SwiftUI

class TestAsyncAwaitParallelImage: Testable {
    static let shared = TestAsyncAwaitParallelImage()
    private init() { }
    
    enum CustomError: Error {
        case invalidURL
    }
    
    var title: String {
        get async {
            //Do something async here
            return "ALTEN"
        }
    }
    
    var url: URL {
        get async throws {
            await Task.sleep(1 * 1_000_000_000) // Wait one seconds
            guard let url = URL(string: "http://www.pforzheim-international.info/resources/PICTURES/BW%20BLACK%20FOREST_HRES.jpg") else { throw CustomError.invalidURL }
            return url
        }
    }
    
    var session: URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .reloadIgnoringCacheData
        return URLSession(configuration: sessionConfig)
    }
    
    public func start() {
        print("[TestAsyncAwaitParallelImage] Start")
        
        Task {
            try await downloadImage1()
            try await downloadImage2()
        }
    }
    
    private func downloadImage1() async throws {
        let url = try await url
        let startDate = Date()
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            //Do something
        }
        let (data1, _) = try await session.data(for: URLRequest(url: url))
        let (data2, _) = try await session.data(for: URLRequest(url: url))
        let (data3, _) = try await session.data(for: URLRequest(url: url))
        let resultImages = [data1, data2, data3]
        
        let resultDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "s.SSS"
        print("[TestAsyncAwaitParallelImage] [1 Slow] - Tiempo de descarga \(dateFormat.string(from: resultDate)) segundos")
    }
    
    private func downloadImage2() async throws {
        let url = try await url
        let startDate = Date()
        
        async let (data1, _) = session.data(for: URLRequest(url: url))
        async let (data2, _) = session.data(for: URLRequest(url: url))
        async let (data3, _) = session.data(for: URLRequest(url: url))
        let resultImages = try await [data1, data2, data3]
        
        let resultDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "s.SSS"
        print("[TestAsyncAwaitParallelImage] [2 Fast] - Tiempo de descarga \(dateFormat.string(from: resultDate)) segundos")
    }
}
