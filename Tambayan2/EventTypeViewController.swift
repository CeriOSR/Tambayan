//
//  EventTypeViewController.swift
//  Tambayan2
//
//  Created by Rey Cerio on 2016-11-24.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

var eventTypeFetch = ""

class EventTypeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct eventTypeObjects {
        
        var title: String?
        var image: UIImage?
        
    }
    
    var eventType: [eventTypeObjects] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //collectionView.reloadData()
    

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogout))
        
        eventType.append(eventTypeObjects(title: "Technology", image: #imageLiteral(resourceName: "tech")))
        
        eventType.append(eventTypeObjects(title: "Outdoors", image: #imageLiteral(resourceName: "outdoors")))
        
        eventType.append(eventTypeObjects(title: "Music", image: #imageLiteral(resourceName: "concerts")))
        
        eventType.append(eventTypeObjects(title: "Education", image: #imageLiteral(resourceName: "education")))
        
        collectionView.delegate = self
        
        collectionView.dataSource = self

    }
    
    //checking for users
    func checkForUser() {
        
        if FIRAuth.auth()?.currentUser == nil {
            
            handleLogout()
            
        }

    }
    
    func handleLogout() {
        
        do {
            //logging out of firebase and going into LoginController
            try FIRAuth.auth()?.signOut()
        } catch let logoutError as NSError {
            print(String(describing: logoutError))
            
        }
        
        //assinging a facebook loginManager
        let loginManager = FBSDKLoginManager()
        //logging the accesstoken out
        loginManager.logOut()
        
        //segueing out to loginController
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return eventType.count
        
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventTypeCell", for: indexPath) as! EventTypeCell
        
        cell.eventType.text = eventType[indexPath.item].title
        
        cell.eventTypeImageView.image = eventType[indexPath.item].image
        
        return cell
        
    }
    
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int{
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        eventTypeFetch = eventType[indexPath.item].title!

        performSegue(withIdentifier: "showEventTableViewControllerSegue", sender: self)
        
    }

}

class EventTypeCell: UICollectionViewCell {
    
    
    @IBOutlet weak var eventTypeImageView: UIImageView!
    
    @IBOutlet weak var eventType: UILabel!
    
    
}
