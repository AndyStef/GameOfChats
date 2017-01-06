//
//  ViewController.swift
//  GameOfChats
//
//  Created by Andy Stef on 10/19/16.
//  Copyright © 2016 Andy Stef. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {

    //MARK: - Variables
    var messages = [Message]()
    let cellId = "cellId"

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogoutTap))
        //TODO: - Add some cool icon here
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(handleNewMessage))

        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: cellId)

        checkIfUserIsLoggedIn()
        observeMessages()
    }

    //MARK: - API methods
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogoutTap), with: nil, afterDelay: 0)
        } else {
            fetchUser()
        }
    }

    //TODO: move to client API
    func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }

        FIRDatabase.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            //TODO: i should defenitely do this when view view is appeared
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavigationBarWith(user: user)
            }
        }, withCancel: nil)
    }

    //MARK: - UI setup
    func setupNavigationBarWith(user: User) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        //TODO: - this centers view but not cut very long names
        //Magic part
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        //Image part
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 17
        profileImageView.clipsToBounds = true

        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }

        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 2).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true

        //Name part
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = titleView
    }
}

//MARK: - TableView methods
extension MessagesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! UserTableViewCell
        cell.message = messages[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

//MARK: - Events and handlers
extension MessagesViewController {

    func handleLogoutTap() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }

        let loginViewController = LoginViewController()
        //MARK: thats not really cool
        loginViewController.messagesController = self
        present(loginViewController, animated: true, completion: nil)
    }

    func handleNewMessage() {
        let newMessageController = NewMessageTableViewController()
        //MARK: thats not really cool
        newMessageController.messagesViewController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        present(navigationController, animated: true, completion: nil)
    }

    func showChatControllerFor(user: User) {
        let chatLogContoller = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogContoller.user = user
        navigationController?.pushViewController(chatLogContoller, animated: true)
    }

    func observeMessages() {
        let reference = FIRDatabase.database().reference().child("messages")
        reference.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)

                //TODO: Google why its not crashing
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
}
