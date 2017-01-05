//
//  ChatLogViewController.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/5/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit
import Firebase

//TODO: Handle keyboard and move view up and down
class ChatLogViewController: UICollectionViewController {

    //MARK: - Variables
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type your message here"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self

        return textField
    }()

    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Chat Log"
        setupInputArea()
    }

    //MARK: - UI Setup methods
    func setupInputArea() {
        //entire container
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        //send button
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSendTap), for: .touchUpInside)

        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        //text field
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        //separator
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.gray

        containerView.addSubview(separatorView)
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}

//MARK: - Events and handlers
extension ChatLogViewController {
    func handleSendTap() {
        let reference = FIRDatabase.database().reference().child("messages")
        let childReference = reference.childByAutoId()
        let values = ["text" : inputTextField.text]
        childReference.updateChildValues(values)
    }
}

//MARK: - textField delegate 
extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendTap()
        return true
    }
}
