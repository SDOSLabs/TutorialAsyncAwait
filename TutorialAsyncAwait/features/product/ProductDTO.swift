//
//  ProductDTO.swift
//  ProductDTO
//
//  Created by Rafael Fernandez Alvarez on 20/9/21.
//

import Foundation

struct ProductDTO: Codable {
    let title: String
    let type: ProductType
    let body: String
    let filename: String
    let height: Double
    let width: Double
    let price: Double
    let rating: Int

    enum CodingKeys: String, CodingKey {
        case body = "description"
        case title, type, filename, height, width, price, rating
    }
    
    var imageURL: URL? { URL(string: "https://raw.githubusercontent.com/SDOSLabs/JSON-Sample/master/Products/images/\(filename)") }
    
    static let mock: ProductDTO = {
        ProductDTO(title: "Brown eggs", type: .dairy, body: "Raw organic brown eggs in a order Raw organic brown eggs in a order Raw organic brown eggs in a order", filename: "0.jpg", height: 600, width: 400, price: 28.1, rating: 4)
    }()
}

extension ProductDTO: Identifiable {
    var id: String { title }
}

enum ProductType: String, Codable {
    case bakery = "bakery"
    case dairy = "dairy"
    case fruit = "fruit"
    case meat = "meat"
    case vegan = "vegan"
    case vegetable = "vegetable"
}
