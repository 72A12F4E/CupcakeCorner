//
//  Order.swift
//  CupcakeCorner
//
//  Created by Blake McAnally on 1/21/21.
//

import SwiftUI

struct Order: Codable {
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 3
    
    var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    var extraFrosting = false
    var addSprinkles = false
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
}

private let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

extension Order {
    var hasValidAddress: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !streetAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !zip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var cost: Decimal {
        // $2 per cake
        var cost = Decimal(quantity) * 2
        
        // complicated cakes cost more
        cost += (Decimal(type) / 2)
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
    
    var formattedCost: String? {
        currencyFormatter.string(from: NSDecimalNumber(decimal: cost))
    }
}

enum OrderError: Error {
    case encodingFailed
    case invalidResponse
    case noData
    case custom(String)
    
    var localizedDescription: String {
        switch self {
        case .encodingFailed:
            return "Failed to encode order"
        case .noData:
            return "No data in response"
        case .invalidResponse:
            return "Invalid response from server"
        case .custom(let string):
            return string
        }
    }
}

class OrderManager: ObservableObject {
    
    @Published var order = Order()
    
    init() {}
    
    func placeOrder(_ completion: @escaping (Result<String, Error>) -> Void) {
        guard let encoded = try? JSONEncoder().encode(order) else {
            completion(.failure(OrderError.encodingFailed))
            return
        }
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(OrderError.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(OrderError.noData))
                return
            }
            if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
                completion(.success("Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"))
            } else {
                completion(.failure(OrderError.invalidResponse))
            }
        }.resume()
    }
}
