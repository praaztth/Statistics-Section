//
//  ChartBySexTableViewCell.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import UIKit
import SwiftUI

class ChartBySexTableViewCell: UITableViewCell {
    func setup(maleCount: Int, femaleCount: Int) {
        let chart = ChartBySex(maleCount: maleCount, femaleCount: femaleCount)
        let hostringController = UIHostingController(rootView: chart)
        
        contentView.addSubview(hostringController.view)
        
        hostringController.view.pin.top(15).left(15).width(of: contentView).height(200)
    }
}

#Preview {
    let cell = ChartBySexTableViewCell()
    cell.setup(maleCount: 5, femaleCount: 10)
    
    return cell
}
