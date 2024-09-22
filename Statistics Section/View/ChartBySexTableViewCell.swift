//
//  ChartBySexTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import UIKit
import SwiftUI

class ChartBySexTableViewCell: UITableViewCell {
    func setup(state: ChartBySexViewController.State) {
        let controller = ChartBySexViewController(state: state)
        let view = controller.chartView
        
        contentView.addSubview(view)
        
        view.pin.top(15).left(15).width(of: contentView).height(200)
    }
}
