//
//  ContentView.swift
//  TradingViewChartTest
//
//  Created by Jiwon Yoon on 3/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                Text("TradingView Chart")
                Spacer()
            }
            .frame(height: 50.0)
            WebView()

            Button(action: {

            }, label: {
                Text("Button")
                    .padding(.horizontal, 20.0)
                    .padding(.vertical, 12.0)
                    .frame(maxWidth: .infinity, minHeight: 56.0)
                    .background(.cyan)
            })
        }
    }
}

#Preview {
    ContentView()
}
