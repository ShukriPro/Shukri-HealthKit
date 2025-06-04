//
//  BottomNav.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//

import SwiftUI

struct BottomNav: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Label("Summary", systemImage: "house")
                }

            ProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .accentColor(.blue) // optional: customize selected tab tint
    }
}

#Preview {
    BottomNav()
}
