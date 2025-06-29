// ContentView.swift

import SwiftUI

struct ContentView: View {
    var body: some View {
        // FoodListView に ViewModel を渡す
        FoodListView(viewModel: FoodViewModel())
    }
}

#Preview {
    ContentView()
}
