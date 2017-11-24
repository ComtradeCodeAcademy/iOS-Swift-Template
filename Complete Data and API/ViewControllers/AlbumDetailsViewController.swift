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

        // Do any additional setup after loading the view.
        
        self.title = "Album Details"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if nil !== self.album {
            
            self.titleLbl.text = album.title
            self.authorLbl.text = album.artist
            
            self.title = album.title
            
            self.albumCoverImgView.imageFromServerURL(urlString: album?.value(forKeyPath: "image") as! String, defaultImage: nil)
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
