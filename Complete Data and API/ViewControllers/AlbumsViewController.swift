//
//  ViewController.swift
//  Complete Data and API
//
//  Created by Pedja Jevtic on 11/22/17.
//  Copyright © 2017 Pedja Jevtic. All rights reserved.
//

import UIKit
import CoreData

class AlbumsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //    MARK: Properties
    
    var albums: [NSManagedObject] = []
    private let cellID = "cell"
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadBttn: UIButton!
    
    // fetch result controller for loading data from CoreData
    
    // create fetch result controller which will be responsible for loading/saving data to DB
    //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/FetchingObjects.html#//apple_ref/doc/uid/TP40001075-CH6-SW1
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Album.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    //    MARK: - Lifecycle methods
    // https://docs-assets.developer.apple.com/published/f06f30fa63/UIViewController_Class_Reference_2x_ddcaa00c-87d8-4c85-961e-ccfb9fa4aac2.png
    // Read more: https://developer.apple.com/documentation/uikit/uiviewcontroller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set title in Navigation Bar
        self.title = "Albums"
        
//        self.tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh our table every time we get back to this controller
        updateTableContent()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //    MARK: - API communication
    // action wich trigger loading albums from API
    @IBAction func loadAlbums(){
        // first, we set observer to catch when response arrived
        NotificationCenter.default.addObserver(self, selector: #selector(albumsLoaded(notification:)), name: Notification.Name.init(API_Paths.music_albums.rawValue), object: nil)
        
        // let's clear existing data to avoid duplication
        // in production, instead of deleting everything and add new, we would go with updating existing content only
        self.clearData()
        self.albums.removeAll()
        self.tableView.reloadData()

        // ok, we are ready now to call API with specified path for specific API resource (albums in this case)
        APIManager.sharedInstance.get(path: API_Paths.music_albums)
    }
    
    // this is method which will catch notification when API data is ready for use
    @objc func albumsLoaded(notification: Notification){
        // since we received data, we don't need to observe it anymore
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(API_Paths.music_albums.rawValue), object: nil)
        
        // check did we get
        if let loadedAlbums = notification.userInfo as? [String: AnyObject]{
            if let dataDict = loadedAlbums["data"] as? [[String:AnyObject]]{
                self.saveInCoreDataWith(array: dataDict)
                
                self.updateTableContent()
            }
            
        }else{
            // display popup with information to user
            self.showAlertWith(title: "Loading failed", message: "Loading albums from API has an issue and couldn't be loaded")
        }
    }
    
    //    MARK: - Table View Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // count number of required columns based on number of albums
        return self.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // initiating cell
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! AlbumTableViewCell
        
        // get album for transferring to AlbumDetails controller
        // and type casting it as Album
        let album = self.fetchedhResultController.fetchedObjects![indexPath.row] as? Album
        
        cell.albumTitleLbl?.text = album?.value(forKeyPath: "title") as? String
        cell.authorLbl?.text = album?.value(forKeyPath: "artist") as? String
        
        // this is method from UIImageView extension
        // we load image from remote source thanks to this additional method we created
        cell.imageView?.imageFromServerURL(urlString: album?.value(forKeyPath: "thumbnail") as! String, defaultImage: nil)
        
        return cell
    }
    // return cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func updateTableContent() {
        
        do {
            // read data from persistent store and fill our NSManagedContext (in RAM memory)
            try self.fetchedhResultController.performFetch()
            // since it's in memory, update our albums list
            self.albums = (self.fetchedhResultController.fetchedObjects as? [NSManagedObject])!
            // reload UITable to show data
            self.tableView.reloadData()
            
            print("SUCCESS: Data loaded from DB")
            print(self.albums)
            
        } catch let error  {
            print("ERROR: \(error)")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // after user tap on one cell, we identify which table is it\
        // load album based on index of the cell (number of row)
        let album = self.fetchedhResultController.fetchedObjects![indexPath.row] as? Album
        
        // send selected album to next viewController as sender (unified temp container)
        self.performSegue(withIdentifier: "openDetails", sender: album)
    }
    
    // MARK: - Core data reading data
    
    private func createAlbumEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        // ok, we got our data from API and its currently just dictionary
        // in order to save it to database, we need to convert it to uniformed type: NSManagedObject
        // read more: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/LifeofaManagedObject.html#//apple_ref/doc/uid/TP40001075-CH16-SW1
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        
        if let albumEntity = NSEntityDescription.insertNewObject(forEntityName: "Album", into: context) as? Album {
            
            albumEntity.artist = dictionary["artist"] as? String
            albumEntity.title = dictionary["title"] as? String
            albumEntity.url = dictionary["url"] as? String
            albumEntity.image = dictionary["image"] as? String
            albumEntity.thumbnail = dictionary["thumbnail_image"] as? String
            
            return albumEntity
        }
        return nil
    }
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        // convert our dictionary to NSManagedObject in order to store it to database
        _ = array.map{self.createAlbumEntityFrom(dictionary: $0)}
        
        do {
            // our NSManagedObjects are created and existing in memory, but not in database yet
            // let's call database persistentContainer with context and store it there
            
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            
            // this will just reload table and display new content in UI
            self.updateTableContent()
            
        } catch let error {
            print(error)
        }
    }
    
    // remove albums data from our persistence store (DB)
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Album.self))
            do {
                // first load objects from database
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                
                // iterate each element and delete it from managedContext (ram memory)
                _ = objects.map{$0.map{context.delete($0)}}
                
                // store changes from managedContext to persistent store (yes, at this moment, our data is still in DB and here we will delete it)
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    // MARK: - Notifications to user
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        
        // display popup view with title, messsage and button(s), aka confirmation dialog
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        // add button with action
        // first, create action
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            // remove popup from UI
            self.dismiss(animated: true, completion: nil)
        }
        // create button and link action we have
        alertController.addAction(action)
        
        // display popup in UI and present it to user
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    // here we are preparing what data we will need to transfer to other controllers, based on name we add to each segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!){

            // from storyboard, we defined this name which will open AlbumDetails, so we need to transfer specific album we selected
        case "openDetails":
            let albumDetailsVC = segue.destination as? AlbumDetailsViewController
            albumDetailsVC?.album = sender as? Album
            
            break
            
        default:
            break
        }
    }
}

// extension to ViewController to enable it to communicate with FetchRequestController (responsible for communication with DB - part of CoreData library)
// https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller
extension AlbumsViewController: NSFetchedResultsControllerDelegate {
    
    // observe if data has been changed in our data structure (in memory) and update's table automatically
    // how's cool is that? :)
    // thanks to this, we could delete some of the cells or insert new and this will update table accordingly
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    // UITable can't be always in edit mode, so this will close edit mode
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    // and yes, this will start edit mode
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}


