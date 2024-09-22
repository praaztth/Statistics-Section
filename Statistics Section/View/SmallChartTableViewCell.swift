//
//  VisitorsChartTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 17.09.2024.
//

import UIKit
import SwiftUI

class SmallChartTableViewCell: UITableViewCell {
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
    
    
    func setup(text: String, count: String, color: Color, type: StatisticsModel.EventType) {
        let controller = SmallChartViewController(type: type, color: color)
        let view = controller.chartView
        
        contentView.addSubview(view)
        contentView.addSubview(countLabel)
        contentView.addSubview(descriptionLabel)
        
        countLabel.text = count
        descriptionLabel.text = text
        
        view.pin.top(15).left(10).height(60).width(95)
        countLabel.pin.after(of: view, aligned: .top).marginLeft(20).right(10).sizeToFit()
        descriptionLabel.pin.after(of: view).marginLeft(20).below(of: countLabel).horizontally().sizeToFit(.width)
    }
}
