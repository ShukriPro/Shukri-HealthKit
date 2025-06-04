//
//  StepComponent.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//
import SwiftUI

struct StepComponent: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            StepSummary()
            Spacer()
            WeeklyStepBar()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct StepSummary: View {
    @State private var currentSteps: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Steps")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Last 7 days")
                .font(.caption2)
                .foregroundColor(.gray)

            HStack(spacing: 2) {
                Text(currentSteps.formatted(.number.grouping(.automatic)))
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .fontWeight(.semibold)

                Text("steps")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Text("Today")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .onAppear {
            HealthKitManager.shared.fetchTodaySteps { steps in
                DispatchQueue.main.async {
                    self.currentSteps = Int(steps)
                }
            }
        }
    }
}
struct WeeklyStepBar: View {
    @State private var steps: [Int] = Array(repeating: 0, count: 7)
    let days = ["T", "F", "S", "S", "M", "T", "W"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { i in
                VStack(spacing: 4) {
                    if steps[i] > 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .offset(y: 5)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue)
                            .frame(width: 20, height: barHeight(for: steps[i]))

                        Text(formatSteps(steps[i]))
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .frame(width: 18)
                    }

                    Text(days[i])
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
            }
        }
        .onAppear {
            HealthKitManager.shared.fetchStepsLast7Days { dailySteps in
                DispatchQueue.main.async {
                    self.steps = dailySteps
                }
            }
        }
    }

    private func barHeight(for value: Int) -> CGFloat {
        let maxHeight: CGFloat = 70
        let minHeight: CGFloat = 20
        let maxValue = steps.max() ?? 1
        let scale = CGFloat(value) / CGFloat(maxValue)
        return max(minHeight, maxHeight * scale)
    }

    private func formatSteps(_ value: Int) -> String {
        value >= 1000 ? "\(value / 1000)k" : "\(value)"
    }
}


#Preview {
    StepComponent()
        .padding()
        .background(Color(.systemGroupedBackground))
}
