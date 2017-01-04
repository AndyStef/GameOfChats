//
//  UserTableViewCell.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/4/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
