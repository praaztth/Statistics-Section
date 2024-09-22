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

struct ChartByAge: View {
    var data = [
        ChartByAgeModel(age: "18-21", countMale: 0, countFemale: 0),
        ChartByAgeModel(age: "22-25", countMale: 0, countFemale: 0),
        ChartByAgeModel(age: "26-30", countMale: 0, countFemale: 0),
        ChartByAgeModel(age: "31-35", countMale: 0, countFemale: 0),
        ChartByAgeModel(age: "36-40", countMale: 0, countFemale: 0),
        ChartByAgeModel(age: "41-50", countMale: 0, countFemale: 0),
        ChartByAgeModel(age: ">50", countMale: 0, countFemale: 0)
    ]
    
    var total: Int = 0
    
    init(maleAges: [Int], femaleAges: [Int]) {
        maleAges.forEach { age in
            defineAgeCategory(age: age) { index in
                data[index].countMale += 1
                total += 1
            }
        }
        
        femaleAges.forEach { age in
            defineAgeCategory(age: age) { index in
                data[index].countFemale += 1
                total += 1
            }
        }
    }
    
    func defineAgeCategory(age: Int, completion: (Int) -> Void) {
        var index: Int? = nil
        switch age {
        case Range(18...21):
            index = data.firstIndex { $0.age == "18-21" }
            
        case Range(22...25):
            index = data.firstIndex { $0.age == "22-25" }
            
        case Range(26...30):
            index = data.firstIndex { $0.age == "26-30" }
            
        case Range(31...35):
            index = data.firstIndex { $0.age == "31-35" }
            
        case Range(36...40):
            index = data.firstIndex { $0.age == "36-40" }
            
        case Range(41...50):
            index = data.firstIndex { $0.age == "41-50" }
            
        case Range(50...150):
            index = data.firstIndex { $0.age == ">50" }
            
        default:
            break
        }
        
        guard let index = index else { return }
        completion(index)
    }
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(x: .value("Count", item.countMale == 0 ? 1 : item.countMale * 100 / total), y: .value("Age", item.age), width: 5)
                    .annotation(position: .trailing) {
                        Text("\(item.countMale * 100 / (total == 0 ? 1 : total))%")
                            .font(.caption2)
                    }
                    .foregroundStyle(by: .value("Sex", "Male"))
                    .position(by: .value("Sex", "Male"))
                    .cornerRadius(10)
                BarMark(x: .value("Count", item.countFemale == 0 ? 1 : item.countFemale * 100 / total), y: .value("Age", item.age), width: 5)
                    .annotation(position: .trailing) {
                        Text("\(item.countFemale * 100 / (total == 0 ? 1 : total))%")
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
    ChartByAge(maleAges: [18, 22, 54], femaleAges: [22, 53, 19])
}
