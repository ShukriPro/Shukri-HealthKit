//
//  ContentView.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    var body: some View {
       BottomNav()
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
