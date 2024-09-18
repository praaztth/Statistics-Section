//
//  ChartBySex.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import SwiftUI
import Charts

struct ChartBySex: View {
    var body: some View {
        Chart {
            SectorMark(angle: .value("Value", 5), innerRadius: .ratio(0.9), angularInset: 4)
                .foregroundStyle(by: .value("Dex", "Male"))
                .cornerRadius(10)
            SectorMark(angle: .value("Value", 2), innerRadius: .ratio(0.9), angularInset: 4)
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
    ChartBySex()
}
