//
//  UIImageView.swift
//  Complete Data and API
//
//  Created by Pedja Jevtic on 11/22/17.
//  Copyright © 2017 Pedja Jevtic. All rights reserved.
//

import UIKit

// exten default UIImage class in order to be able to download images from URL (string)
extension UIImageView {
    
    public func imageFromServerURL(urlString: String, defaultImage : String?) {
        // in case our image can't be downloaded, we define default image
        if let di = defaultImage {
            self.image = UIImage(named: di)
        }
        // start communication with server
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            // error handling: print in console what type of error happened
            if error != nil {
                print(error ?? "error")
                return
            }
            // since it's happening on separate thread we need to update our imageView on main thread
            DispatchQueue.main.async(execute: { () -> Void in
                // we receive image as NSData type so we need to initialize image from that data
                let image = UIImage(data: data!)
                // assign new image to given UIImageView (which is reference of self)
                self.image = image
                
                
                
            })
            
        }).resume()
    }
}
