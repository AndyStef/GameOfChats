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

    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }

    let cellId = "cellId"
    var messages = [Message]()

    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        setupInputArea()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    //MARK: - UI Setup methods
    func setupInputArea() {
        //entire container
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
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

//MARK: - CollectionVIew methods 
extension ChatLogViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCollectionViewCell
        let message = messages[indexPath.item]
        //TODO: - what is difference between indexPath.item and row
        cell.textView.text = message.text
        let estimatedWidth = estimateFrameForText(text: message.text ?? "").width + 32
        cell.bubbleWidthAnchor?.constant = estimatedWidth

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80.0

        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }

        return CGSize(width: view.frame.width, height: height)
    }

    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
}

//MARK: - Events and handlers
extension ChatLogViewController {
    func handleSendTap() {
        let reference = FIRDatabase.database().reference().child("messages")
        let childReference = reference.childByAutoId()

        guard let toId = user?.id, let fromId = FIRAuth.auth()?.currentUser?.uid, let text = inputTextField.text else {
            return
        }

        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let values = ["text" : text, "toId" : toId, "fromId" : fromId, "timestamp" : timestamp] as [String : Any]
        childReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
            if let error = error {
                print(error)
                return
            }

            self.inputTextField.text = nil

            let userMessageReference = FIRDatabase.database().reference().child("user-message").child(fromId)
            let messageId = childReference.key
            userMessageReference.updateChildValues([messageId : 1])

            let recepientsUserMessagesReference = FIRDatabase.database().reference().child("user-message").child(toId)
            recepientsUserMessagesReference.updateChildValues([messageId : 1])
        })
    }

    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }

        let userMessageReference = FIRDatabase.database().reference().child("user-message").child(uid)
        userMessageReference.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }

                let message = Message()
                message.setValuesForKeys(dictionary)

                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            })
        })
    }
}

//MARK: - textField delegate 
extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendTap()
        return true
    }
}
