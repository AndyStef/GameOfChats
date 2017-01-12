//
//  ChatInputContainerView.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/12/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView {

    var chatLogController: ChatLogViewController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(chatLogController?.handleSendTap), for: .touchUpInside)
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(chatLogController?.handlePickImageTap)))
            inputTextField.delegate = chatLogController
        }
    }

    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type your message here"
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()

    let sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)

        return sendButton
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "PickImage")
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true

        return imageView
    }()

    let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.gray

        return separatorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.white

        addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        //send button
        addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

        //text field
        addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

        //separator
        addSubview(separatorView)
        separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

