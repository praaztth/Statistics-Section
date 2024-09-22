//
//  VisitorsBigChartTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 17.09.2024.
//

import UIKit
import SwiftUI

class VisitorsBigChartTableViewCell: UITableViewCell {
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
    
    
    func setup(state: VisitorsChartViewController.State) {
        let controller = VisitorsChartViewController(state: state)
        let view = controller.chartView
        
        contentView.addSubview(view)
        
        view.pin.top(15).left(20).width(of: contentView).height(190)
    }
}
