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
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Album.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    //    MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Albums"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableContent()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //    MARK: - API communication
    
    @IBAction func loadAlbums(){
        NotificationCenter.default.addObserver(self, selector: #selector(albumsLoaded(notification:)), name: Notification.Name.init(API_Paths.music_albums.rawValue), object: nil)
        
        self.clearData()
        self.albums.removeAll()
        self.tableView.reloadData()
        
        APIManager.sharedInstance.get(path: API_Paths.music_albums)
    }
    
    @objc func albumsLoaded(notification: Notification){
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(API_Paths.music_albums.rawValue), object: nil)
        
        if let loadedAlbums = notification.userInfo as? [String: AnyObject]{
            if let dataDict = loadedAlbums["data"] as? [[String:AnyObject]]{
                self.saveInCoreDataWith(array: dataDict)
                
                self.updateTableContent()
            }
            
        }else{
            self.showAlertWith(title: "Loading failed", message: "Loading albums from API has an issue and couldn't be loaded")
        }
    }
    
    //    MARK: - Table View Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! AlbumTableViewCell
        
        let album = self.fetchedhResultController.fetchedObjects![indexPath.row] as? Album
        
        cell.albumTitleLbl?.text = album?.value(forKeyPath: "title") as? String
        cell.authorLbl?.text = album?.value(forKeyPath: "artist") as? String
        
        cell.imageView?.imageFromServerURL(urlString: album?.value(forKeyPath: "thumbnail") as! String, defaultImage: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func updateTableContent() {
        
        do {
            try self.fetchedhResultController.performFetch()
            
            self.albums = (self.fetchedhResultController.fetchedObjects as? [NSManagedObject])!
            self.tableView.reloadData()
            
            print("SUCCESS: Data loaded from DB")
            print(self.albums)
            
        } catch let error  {
            print("ERROR: \(error)")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = self.fetchedhResultController.fetchedObjects![indexPath.row] as? Album
        
        self.performSegue(withIdentifier: "openDetails", sender: album)
    }
    
    // MARK: - Core data reading data
    
    private func createAlbumEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
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
        _ = array.map{self.createAlbumEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            self.updateTableContent()
            
        } catch let error {
            print(error)
        }
    }
    
    private func clearData() {
        do {
            
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Album.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    // MARK: - Notifications to user
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Nagivation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!){
            
        case "openDetails":
            let albumDetailsVC = segue.destination as? AlbumDetailsViewController
            albumDetailsVC?.album = sender as? Album
            
            break
            
        default:
            break
        }
    }
}

extension AlbumsViewController: NSFetchedResultsControllerDelegate {
    
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}


