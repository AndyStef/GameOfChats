//
//  Message.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/6/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?

    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
