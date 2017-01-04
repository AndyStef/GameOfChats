//
//  ViewController.swift
//  GameOfChats
//
//  Created by Andy Stef on 10/19/16.
//  Copyright © 2016 Andy Stef. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogoutTap))

        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogoutTap), with: nil, afterDelay: 0)
        }
    }
}

//MARK: - Events and handlers
extension ViewController {

    func handleLogoutTap() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }

        let loginViewController = LoginViewController()
        present(loginViewController, animated: true, completion: nil)
    }
}
