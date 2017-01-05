//
//  NewMessageTableViewController.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/4/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {

    //MARK: - Variables
    let cellId = "cellId"
    var users = [User]()

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelTap))
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: cellId)

        fetchUser()
    }

    //MARK: - API funcs
    //TODO: Move this into client API
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                //This works like AutoMapper every field should match, else it would crash
                user.setValuesForKeys(dictionary)
//                user.name = dictionary["name"] as? String
//                user.email = dictionary["email"] as? String
                self.users.append(user)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
}

//MARK: - Table view methods 
extension NewMessageTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserTableViewCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

//MARK: - events and handlers
extension NewMessageTableViewController {
    func handleCancelTap() {
        dismiss(animated: true, completion: nil)
    }
}
