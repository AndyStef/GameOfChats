//
//  ViewController.swift
//  GameOfChats
//
//  Created by Andy Stef on 10/19/16.
//  Copyright © 2016 Andy Stef. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogoutTap))
    }

}

//MARK: - Events and handlers
extension ViewController {

    func handleLogoutTap() {
        let loginViewController = LoginViewController()
        present(loginViewController, animated: true, completion: nil)
    }
}
