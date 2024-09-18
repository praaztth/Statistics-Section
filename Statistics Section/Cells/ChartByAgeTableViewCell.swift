//
//  ChartByAgeTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import UIKit
import SwiftUI

class ChartByAgeTableViewCell: UITableViewCell {
    func setup() {
        let chart = ChartByAge()
        let hostringController = UIHostingController(rootView: chart)
        
        contentView.addSubview(hostringController.view)
        
        hostringController.view.pin.top().left(60).width(contentView.frame.width - 30).height(320)
    }
}
