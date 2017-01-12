//
//  ChatLogViewController.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/5/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

//TODO: Handle keyboard and move view up and down
class ChatLogViewController: UICollectionViewController {

    //MARK: - Variables

    lazy var inputContainerView: ChatInputContainerView = {
        let containerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        containerView.chatLogController = self

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
        cell.message = message
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

        cell.playButton.isHidden = message.videoUrl == nil

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

    func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let reference = FIRStorage.storage().reference().child("message_images").child("\(imageName).jpg")

        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            reference.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
    }

    func sendMessageWith(imageUrl: String, image: UIImage) {
        let properties = ["imageUrl" : imageUrl, "imageWidth" :  image.size.width, "imageHeight" : image.size.height] as [String : Any]
        sendMessageWith(properties: properties)
    }

    func sendMessageWith(videoUrl: String, image: UIImage, imageUrl: String) {
        let properties = ["videoUrl" : videoUrl, "imageUrl" : imageUrl, "imageWidth" :  image.size.width, "imageHeight" : image.size.height] as [String : Any]
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

            self.inputContainerView.inputTextField.text = nil

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
        guard let text = inputContainerView.inputTextField.text else {
            return
        }

        let properties = ["text" : text]
        sendMessageWith(properties: properties)
    }

    func handlePickImageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
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
        //MARK: this actually cause a bug
        //zoomImageView.clipsToBounds = true
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

        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelectedFor(url: videoUrl)
        } else {
            handleImageSelectedFor(info: info)
        }

        dismiss(animated: true, completion: nil)
    }

    private func handleImageSelectedFor(info: [String : Any]) {
        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            uploadImageToFirebaseStorage(selectedImage, completion: { (url) in
                self.sendMessageWith(imageUrl: url, image: selectedImage)
            })
        }
    }

    private func handleVideoSelectedFor(url: URL) {
        let filename = NSUUID().uuidString + ".mov"

        let uploadTask = FIRStorage.storage().reference().child("message_videos").child(filename).putFile(url, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print(error)
                return
            }

            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageFor(fileUrl: url) {
                    self.uploadImageToFirebaseStorage(thumbnailImage, completion: { (url) in
                        self.sendMessageWith(videoUrl: videoUrl, image: thumbnailImage, imageUrl: url)
                    })
                }
            }
        })

        uploadTask.observe(.progress) { (snapshot) in
            if let comletedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(comletedUnitCount)
            }
        }

        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }

    private func thumbnailImageFor(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
}

//MARK: - textField delegate 
extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendTap()
        return true
    }
}
