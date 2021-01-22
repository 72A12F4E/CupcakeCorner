//
//  AddressView.swift
//  CupcakeCorner
//
//  Created by Blake McAnally on 1/21/21.
//

import SwiftUI

struct AddressView: View {
    @ObservedObject var manager: OrderManager

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $manager.order.name)
                TextField("Street Address", text: $manager.order.streetAddress)
                TextField("City", text: $manager.order.city)
                TextField("Zip", text: $manager.order.zip)
            }

            Section {
                NavigationLink(destination: CheckoutView(manager: manager)) {
                    Text("Check out")
                }
            }.disabled(!manager.order.hasValidAddress)
        }
        .navigationBarTitle("Delivery details", displayMode: .inline)
    }
}
