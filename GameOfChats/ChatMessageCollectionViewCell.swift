//
//  ChatMessageCollectionViewCell.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/7/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit

class ChatMessageCollectionViewCell: UICollectionViewCell {

    //MARK: - Variables
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "sample ttestatastasaf"
        textView.font = UIFont.systemFont(ofSize: 16)

        return textView
    }()

    //MARK: - Cell  initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textView)
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
