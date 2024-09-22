//
//  ChartBySex.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import SwiftUI
import Charts

struct ChartBySex: View {
    var maleCount: Int
    var femaleCount: Int
    
    init(maleCount: Int, femaleCount: Int) {
        self.maleCount = maleCount
        self.femaleCount = femaleCount
    }
    
    var body: some View {
        Chart {
            SectorMark(angle: .value("Value", maleCount), innerRadius: .ratio(0.9), angularInset: 4)
                .foregroundStyle(by: .value("Sex", "Male"))
                .cornerRadius(10)
            SectorMark(angle: .value("Value", femaleCount), innerRadius: .ratio(0.9), angularInset: 4)
                .foregroundStyle(by: .value("Sex", "Female"))
                .cornerRadius(10)
        }
        .chartForegroundStyleScale([
            "Male": Color.red,
            "Female": Color.orange
        ])
    }
}

#Preview {
    ChartBySex(maleCount: 3, femaleCount: 6)
}
