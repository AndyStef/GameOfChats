//
//  UIImageView.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/5/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit

//MARK: Swift 3 issue
let imageCache = NSCache<NSString, UIImage>()
//let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWith(urlString: String) {
        //TODO: - thats for no flashes, maybe prepare for reuse is better
        self.image = nil
        
        //check cache for image first 
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }

        //TODO: - Refactor this using Alamofire
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = UIImage(data: data!)
                }
            })
        }).resume()
    }
}

