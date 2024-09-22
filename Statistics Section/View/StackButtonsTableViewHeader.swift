//
//  StackButtonsTableViewHeader.swift
//  Statistics Section
//
//  Created by tryuruy on 16.09.2024.
//

import UIKit
import PinLayout

class StackButtonsTableViewHeader: UITableViewHeaderFooterView {
    static let reuserIdentifier = "StackButtonsTableViewHeader"
    
//    let collectionView: UICollectionView = {
//        let view = UICollectionView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        return view
//    }()
    
//    let stack: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.alignment = .leading
//        stack.spacing = 8
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        
//        return stack
//    }()
    
    let scrollView = UIScrollView()
    
    let dayButton = UIButton()
    let weekButton = UIButton()
    let monthButton = UIButton()
    var allPeriodButton: UIButton? = nil
    
    let buttons: [UIButton]
    
    init(buttonTitles: [String]) {
        if buttonTitles.count == 4 {
            allPeriodButton = UIButton()
        }
        
        buttons = [dayButton, weekButton, monthButton, allPeriodButton].compactMap { $0 }
        for i in 0..<buttons.count {
            buttons[i].setTitle(buttonTitles[i], for: .normal)
        }
        
        super.init(reuseIdentifier: nil)
        
        configureButtons()
        setupSubviews()
        
//        activateConstrains()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.pin.all()
        
        dayButton.pin.left().top()
        weekButton.pin.after(of: dayButton, aligned: .center).marginLeft(10)
        monthButton.pin.after(of: weekButton, aligned: .center).marginLeft(10)
        
        var lastButton = monthButton
        if let button = allPeriodButton {
            button.pin.after(of: monthButton, aligned: .center).marginLeft(10)
            lastButton = button
        }
        
        scrollView.contentSize.width = lastButton.frame.maxX
        
    }
    
    func setupSubviews() {
        contentView.addSubview(scrollView)
        
        buttons.forEach { scrollView.addSubview($0) }
    }
    
    func configureButtons() {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        
        buttons.forEach { button in
            button.configuration = config
//            button.setTitleColor(.black, for: .normal)
//            button.setTitleColor(.white, for: .selected)
//            button.setBackgroundImage(UIColor.red.image(), for: .normal)
//            button.setBackgroundImage(UIColor.red.image(), for: .selected)
//            button.tintColor = .clear
            
//            button.layer.borderColor = UIColor.secondaryLabel.cgColor
            button.layer.cornerRadius = 18
            
            button.configurationUpdateHandler = { button in
                if button.isSelected {
                    button.configuration?.baseForegroundColor = .white
                    button.configuration?.baseBackgroundColor = .red
                    button.layer.borderWidth = 0
                } else {
                    button.configuration?.baseForegroundColor = .black
                    button.configuration?.baseBackgroundColor = .clear
                    button.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.3).cgColor
                    button.layer.borderWidth = 1
                }
            }
            
            button.sizeToFit()
        }
        
//        dayButton.isSelected = true
    }
    
//    func activateConstrains() {
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
//            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
//            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor)
//        ])
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    StackButtonsTableViewHeader(buttonTitles: [
        "По дням",
        "По неделям",
        "По месяцам",
        "all time"
    ])
}
