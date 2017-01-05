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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogoutTap))
        //TODO: - Add some cool icon here
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(handleNewMessage))

        checkIfUserIsLoggedIn()
    }

    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogoutTap), with: nil, afterDelay: 0)
        } else {
            fetchUser()
        }
    }

    //TODO: - move to client API
    func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }

        FIRDatabase.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            //TODO: - i should defenitely do this when view view is appeared
            if let dictionary = snapshot.value as? [String : AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
            }
        }, withCancel: nil)
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
        //MARK: - thats not really cool
        loginViewController.messagesController = self
        present(loginViewController, animated: true, completion: nil)
    }

    func handleNewMessage() {
        let newMessageController = NewMessageTableViewController()
        let navigationController = UINavigationController(rootViewController: newMessageController)
        present(navigationController, animated: true, completion: nil)
    }
}
