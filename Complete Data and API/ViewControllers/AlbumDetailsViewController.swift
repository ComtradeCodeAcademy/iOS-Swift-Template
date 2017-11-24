//
//  AlbumDetailsViewController.swift
//  Complete Data and API
//
//  Created by Pedja Jevtic on 11/22/17.
//  Copyright © 2017 Pedja Jevtic. All rights reserved.
//

import UIKit

class AlbumDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    var album: Album!
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var albumCoverImgView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default title of ViewController
        self.title = "Album Details"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if nil !== self.album {
            
            // fill album details we got from previous ViewController
            self.titleLbl.text = album.title
            self.authorLbl.text = album.artist
            
            // refresh title
            self.title = album.title
            
            // load cover image for album
            // this is defined in extension of UIImageView
            if let image = album?.value(forKeyPath: "image") as? String {
            self.albumCoverImgView.imageFromServerURL(urlString: image, defaultImage: "artistDefaultImage")
        }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
