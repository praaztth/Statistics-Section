//
//  UserCell.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import UIKit

class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"
    
    let avatarContainer = UIView()
    
    let avatarView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    let badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarContainer)
        contentView.addSubview(titleLabel)
        avatarContainer.addSubview(avatarView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(title: String, isOnline: Bool, imageData: Data?) {
        titleLabel.text = title
        
        if let imageData = imageData {
            avatarView.image = UIImage(data: imageData)
        } else {
            avatarView.image = UIImage(systemName: "trash.slash.square.fill")
        }
        
        if isOnline {
            avatarContainer.addSubview(badgeView)
        }
    }
    
    override func prepareForReuse() {
        avatarView.image = nil
        titleLabel.text = nil
        badgeView.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarContainer.pin.left(15).vCenter().wrapContent()
        avatarView.pin.center().vCenter().size(CGSize(width: 40, height: 40))
        badgeView.pin.right().bottom().size(CGSize(width: 10, height: 10))
        titleLabel.pin.after(of: avatarContainer, aligned: .center).marginLeft(10).sizeToFit()
        
        
    }
}

//#Preview {
//    let cell = UserCell()
//    cell.setup(title: "dsgdsgd, 25")
//    
//    return cell
//}
