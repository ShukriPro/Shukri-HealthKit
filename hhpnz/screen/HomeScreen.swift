//
//  HomeScreen.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    StepComponent()
                    SleepComponent()
                    HeartComponent()
                    ActiveEnergyComponent()
                    RespiratoryComponent()
                    StandTimeComponent()
                }
                .padding()
            }
            .onAppear {
                       HealthKitManager.shared.requestAuthorization { success in
                           print(success ? "✅ HealthKit access granted" : "❌ HealthKit access denied")
                       }
                   }
        }
    }
}

#Preview {
    HomeScreen()
}
