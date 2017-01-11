//
//  ChatMessageCollectionViewCell.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/7/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCollectionViewCell: UICollectionViewCell {

    //MARK: - Variables
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.isEditable = false

        return textView
    }()

    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true 

        return view
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    lazy var messageImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))

        return image
    }()

    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon-play"), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)

        return button
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        aiv.isHidden = true

        return aiv
    }()

    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var chatLogController: ChatLogViewController?
    var message: Message?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?

    //MARK: - Cell  initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        addSubview(bubbleView)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)

        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true

        addSubview(textView)
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true

        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        bubbleView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }

    func handleImageTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != {
            return
        }

        guard let imageView = tapGesture.view as? UIImageView else {
            return
        }
        
        //TODO: is that better to do this way or using closures
        chatLogController?.handleZoomFor(image: imageView)
    }

    func handlePlayVideo() {
        guard let videoUrl = message?.videoUrl, let url = URL(string: videoUrl) else {
            return
        }

        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubbleView.bounds
        bubbleView.layer.addSublayer(playerLayer!)
        player?.play()
        activityIndicatorView.startAnimating()
        playButton.isHidden = true
    }
}
