//
//  ChartByAge.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import SwiftUI
import Charts

struct ChartByAgeModel: Identifiable {
    var id = UUID()
    var age: String
    var countMale: Int
    var countFemale: Int
}

let datasource = [
    ChartByAgeModel(age: "18-21", countMale: 10, countFemale: 20),
    ChartByAgeModel(age: "22-25", countMale: 20, countFemale: 30),
    ChartByAgeModel(age: "26-30", countMale: 5, countFemale: 0),
    ChartByAgeModel(age: "31-35", countMale: 0, countFemale: 0),
    ChartByAgeModel(age: "36-40", countMale: 5, countFemale: 0),
    ChartByAgeModel(age: "40-50", countMale: 0, countFemale: 10),
    ChartByAgeModel(age: ">50", countMale: 100, countFemale: 0)
]

struct ChartByAge: View {
    var body: some View {
        Chart {
            ForEach(datasource) { item in
                BarMark(x: .value("Count", item.countMale == 0 ? 1 : item.countMale), y: .value("Age", item.age), width: 5)
                    .annotation(position: .trailing) {
                        Text("\(item.countMale)%")
                            .font(.caption2)
                    }
//                    .annotation(position: .leading, spacing: 30) {
//                        Text(item.age)
//                            .offset(y: 10)
//                    }
                    .foregroundStyle(by: .value("Sex", "Male"))
                    .position(by: .value("Sex", "Male"))
                    .cornerRadius(10)
                BarMark(x: .value("Count", item.countFemale == 0 ? 1 : item.countFemale), y: .value("Age", item.age), width: 5)
                    .annotation(position: .trailing) {
                        Text("\(item.countFemale)%")
                            .font(.caption2)
                    }
                    .foregroundStyle(by: .value("Sex", "Female"))
                    .position(by: .value("Sex", "Female"))
                    .cornerRadius(10)
            }
            
        }
        .chartXAxis() {
            AxisMarks(values: [100], stroke: .init(lineWidth: 0))
        }
        .chartYAxis() {
            AxisMarks {
                AxisTick()
                AxisValueLabel(centered: true, horizontalSpacing: -50)
                    .font(.caption2)
            }
        }
        .chartLegend(.hidden)
        .chartForegroundStyleScale([
            "Male": Color.red,
            "Female": Color.orange
        ])
    }
}

#Preview {
    ChartByAge()
}
