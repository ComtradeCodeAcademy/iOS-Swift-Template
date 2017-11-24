//
//  UIImageView.swift
//  Complete Data and API
//
//  Created by Pedja Jevtic on 11/22/17.
//  Copyright © 2017 Pedja Jevtic. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func imageFromServerURL(urlString: String, defaultImage : String?) {
        if let di = defaultImage {
            self.image = UIImage(named: di)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
                self.layoutSubviews()
                
            })
            
        }).resume()
    }
}
