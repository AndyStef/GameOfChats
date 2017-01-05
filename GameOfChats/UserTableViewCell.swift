//
//  UserTableViewCell.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/4/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    let profileImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 24
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill

        return image
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)

        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.size.width, height: textLabel!.frame.size.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.size.width, height: detailTextLabel!.frame.size.height)
    }
}
