//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Blake McAnally on 1/21/21.
//

import SwiftUI



struct CheckoutView: View {
    @ObservedObject var manager: OrderManager
    
    @State private var isShowingAlert = false
    @State private var orderResponse: Result<String, Error> = .success("")

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)

                    if let cost = manager.order.formattedCost {
                        Text("Your total is \(cost)")
                            .font(.title)
                        Button("Place Order") {
                            manager.placeOrder { result in
                                orderResponse = result
                                isShowingAlert = true
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            makeAlert(orderResponse)
        }
        .navigationBarTitle("Check out", displayMode: .inline)
    }
    
    private func makeAlert(_ response: Result<String, Error>) -> Alert {
        switch orderResponse {
        case .success(let message):
            return Alert(
                title: Text("Thank you!"),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        case .failure(let error):
            return Alert(
                title: Text("Uh oh..."),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
