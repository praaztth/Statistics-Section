//
//  VisitorsBigChartTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 17.09.2024.
//

import UIKit
import SwiftUI

class VisitorsBigChartTableViewCell: UITableViewCell {
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
    
    
    func setup(data: [Double: Int]) {
        let chartView = BigChartView(data: data)
        let hostingController = UIHostingController(rootView: chartView)
        
        contentView.addSubview(hostingController.view)
        
        hostingController.view.pin.top(15).left(20).width(of: contentView).height(190)
    }
}
