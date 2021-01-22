//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Blake McAnally on 1/21/21.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var manager = OrderManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Select your cake type", selection: $manager.order.type) {
                        ForEach(0..<Order.types.count) {
                            Text(Order.types[$0])
                        }
                    }

                    Stepper(value: $manager.order.quantity, in: 3...20) {
                        Text("Number of cakes: \(manager.order.quantity)")
                    }
                }
                
                Section {
                    Toggle(isOn: $manager.order.specialRequestEnabled.animation()) {
                        Text("Any special requests?")
                    }

                    if manager.order.specialRequestEnabled {
                        Toggle(isOn: $manager.order.extraFrosting) {
                            Text("Add extra frosting")
                        }

                        Toggle(isOn: $manager.order.addSprinkles) {
                            Text("Add extra sprinkles")
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: AddressView(manager: manager)) {
                        Text("Delivery details")
                    }
                }
            }
            .navigationBarTitle("Cupcake Corner")
        }
    }
}
