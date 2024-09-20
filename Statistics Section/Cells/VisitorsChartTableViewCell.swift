//
//  VisitorsChartTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 17.09.2024.
//

import UIKit
import SwiftUI

class VisitorsSmallChartTableViewCell: UITableViewCell {
    let view = UIView()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        
        return label
    }()
    
    
    func setup(text: String, count: String, color: Color, data: [Double: Int]) {
        let chartView = ChartView(color: color, data: data)
        let hostingController = UIHostingController(rootView: chartView)
        
        contentView.addSubview(hostingController.view)
        contentView.addSubview(countLabel)
        contentView.addSubview(descriptionLabel)
        
        countLabel.text = count
        descriptionLabel.text = text
        
        hostingController.view.pin.top(15).left(10).height(60).width(95)
        countLabel.pin.after(of: hostingController.view, aligned: .top).marginLeft(20).right(10).sizeToFit()
        descriptionLabel.pin.after(of: hostingController.view).marginLeft(20).below(of: countLabel).horizontally().sizeToFit(.width)
    }
}

//#Preview {
//    let cell = VisitorsSmallChartTableViewCell()
//    cell.setup(text: "Количество посетителей в этом месяце выросло", count: "1356")
//    
//    return cell
//}
