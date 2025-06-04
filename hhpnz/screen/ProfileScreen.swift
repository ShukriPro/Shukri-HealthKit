//
//  ProfileScreen.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//

import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)

            Text("Your Name")
                .font(.headline)

            Text("your.email@example.com")
                .font(.caption)
                .foregroundColor(.gray)

            Button(action: {
                // TODO: Add logout logic
            }) {
                Text("Logout")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    ProfileScreen()
}
