//
//  ChartByAgeTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import UIKit
import SwiftUI

class ChartByAgeTableViewCell: UITableViewCell {
    func setup(state: ChartByAgeViewController.State) {
        let controller = ChartByAgeViewController(state: state)
        let view = controller.chartView
        
        contentView.addSubview(view)
        
        view.pin.top().left(60).width(contentView.frame.width - 30).height(320)
    }
}
