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

    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "PickImage")
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickImageTap)))
        imageView.isUserInteractionEnabled = true

        containerView.addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

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
        containerView.addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
        //separator
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.gray

        containerView.addSubview(separatorView)
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }

    let cellId = "cellId"
    var messages = [Message]()
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?

    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        setupKeyboardObservers()
    }

    override func viewWillTransition(to size: CGSize, with coordinator:
        UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - CollectionVIew methods 
extension ChatLogViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCollectionViewCell
        cell.chatLogController = self
        let message = messages[indexPath.item]
        //TODO: - what is difference between indexPath.item and row
        cell.textView.text = message.text
        setupCell(cell, message: message)

        if let text = message.text {
            let estimatedWidth = estimateFrameForText(text: text).width + 32
            cell.bubbleWidthAnchor?.constant = estimatedWidth
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }

        return cell
    }

    private func setupCell(_ cell: ChatMessageCollectionViewCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }

        if message.toId == FIRAuth.auth()?.currentUser?.uid {
            //messages addressed to me
            cell.bubbleView.backgroundColor = UIColor.red
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
            cell.profileImageView.isHidden = false
        } else {
            //messages that i sent
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 249)
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        }

        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.isHidden = false
            cell.messageImageView.loadImageUsingCacheWith(urlString: messageImageUrl)
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80.0
        let message = messages[indexPath.item]

        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageHeight = message.imageHeight?.floatValue, let imageWidth = message.imageWidth?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }

        //MARK: Another hack to fix constraints issues
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }

    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
}

//MARK: - API methods 
extension ChatLogViewController {
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let chatPartnerId = user?.id else {
            return
        }

        let userMessageReference = FIRDatabase.database().reference().child("user-message").child(uid).child(chatPartnerId)
        userMessageReference.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }

                let message = Message(dictionary: dictionary)
                self.messages.append(message)

                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        })
    }

    func uploadImageToFirebaseStorage(_ image: UIImage) {
        let imageName = NSUUID().uuidString
        let reference = FIRStorage.storage().reference().child("message_images").child("\(imageName).jpg")

        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            reference.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWith(imageUrl: imageUrl, image: image)
                }
            })
        }
    }

    private func sendMessageWith(imageUrl: String, image: UIImage) {
        let properties = ["imageUrl" : imageUrl, "imageWidth" :  image.size.width, "imageHeight" : image.size.height] as [String : Any]
        sendMessageWith(properties: properties)
    }

    func sendMessageWith(properties: [String : Any]) {
        let reference = FIRDatabase.database().reference().child("messages")
        let childReference = reference.childByAutoId()

        guard let toId = user?.id, let fromId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }

        //fix of this issue in Swift 3
        let timestamp = NSNumber(value: NSDate().timeIntervalSince1970)
        //let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        var values = ["toId" : toId, "fromId" : fromId, "timestamp" : timestamp] as [String : Any]
        properties.forEach({values[$0] = $1})

        childReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
            if let error = error {
                print(error)
                return
            }

            self.inputTextField.text = nil

            let userMessageReference = FIRDatabase.database().reference().child("user-message").child(fromId).child(toId)
            let messageId = childReference.key
            userMessageReference.updateChildValues([messageId : 1])

            let recepientsUserMessagesReference = FIRDatabase.database().reference().child("user-message").child(toId).child(fromId)
            recepientsUserMessagesReference.updateChildValues([messageId : 1])
        })
    }
}

//MARK: - Events and handlers
extension ChatLogViewController {
    func handleSendTap() {
        guard let text = inputTextField.text else {
            return
        }

        let properties = ["text" : text]
        sendMessageWith(properties: properties)
    }

    func handlePickImageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    func handleZoomFor(image: UIImageView) {
        self.startingImageView = image
        self.startingImageView?.isHidden = true
        startingFrame = image.superview?.convert(image.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = image.image
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomOut)))

        if let keyWindow = UIApplication.shared.keyWindow {
            self.blackBackgroundView = UIView(frame: keyWindow.frame)
            self.blackBackgroundView?.backgroundColor = UIColor.black
            self.blackBackgroundView?.alpha = 0
            keyWindow.addSubview(self.blackBackgroundView ?? UIView())

            keyWindow.addSubview(zoomingImageView)
            //Brians variant
           // let neededHeight = zoomingImageView.frame.height / keyWindow.frame.width * keyWindow.frame.height
            //My var
            let neededHeight = zoomingImageView.frame.height * keyWindow.frame.width / keyWindow.frame.height

            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.blackBackgroundView?.alpha = 1.0
                self.inputContainerView.alpha = 0
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: neededHeight)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }

    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        guard let zoomImageView = tapGesture.view as? UIImageView else {
            return
        }

        //TODO: what is real difference between view.clipsToBounds and view.layer.masksToBounds
        zoomImageView.clipsToBounds = true
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            zoomImageView.frame = self.startingFrame!
            zoomImageView.layer.cornerRadius = 16
            self.blackBackgroundView?.alpha = 0.0
            self.inputContainerView.alpha = 1.0
        }) { (completed) in
            self.blackBackgroundView?.removeFromSuperview()
            zoomImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        }
    }
}

//TODO: - Maybe move this out to code snippet
//MARK: - imagePicker delegate 
extension ChatLogViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            uploadImageToFirebaseStorage(selectedImage)
        }

        dismiss(animated: true, completion: nil)
    }
}

//MARK: - textField delegate 
extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendTap()
        return true
    }
}
