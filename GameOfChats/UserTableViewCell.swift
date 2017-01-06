//
//  UserTableViewCell.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/4/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewCell: UITableViewCell {

    //MARK: - Variables
    //MARK: model
    var message: Message? {
        didSet {
            if let toId = message?.toId {
                let reference = FIRDatabase.database().reference().child("users").child(toId)
                reference.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String : AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String

                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            self.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
                        }
                    }
                })
            }

            self.detailTextLabel?.text = message?.text

            if let timestamp = message?.timestamp {
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormatter.string(from: date)
            }
        }
    }

    var user: User? {
        didSet {
            self.textLabel?.text = user?.name
            self.detailTextLabel?.text = user?.email

            if let profileImageUrl = user?.profileImageUrl {
                self.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
            }

            //TODO: Ask someone what is better to set its hidden or just remove
            timeLabel.removeFromSuperview()
        }
    }

    //MARK: view
    let profileImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 24
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill

        return image
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray

        return label
    }()

    //MARK: - Cell itself
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)

        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        addSubview(timeLabel)

        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
