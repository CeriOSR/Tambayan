//
//  EventsTableViewController.swift
//  Tambayan
//
//  Created by Rey Cerio on 2016-11-09.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

//global vars for the EventDetailsController
var detailTitle: String?
var detailDate: String?
var detailImage: String?
var detailLocation: String?
var detailPrice: String?
var detailType: String?
var detailDescription: String?

var detailEvents = [Events]() //used in detailEvents
var uniVarEvents = [Events]()

class EventsTableViewController: UITableViewController {
    
    @IBAction func logout(_ sender: AnyObject) {
        
        handleLogout()
        
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
        performSegue(withIdentifier: "noUserSegue", sender: self)
        
    }

    
    
    @IBAction func addEvent(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "addEventSegue", sender: self)
        
    }
    
    //checking for users
    func checkForUser() {
        
        if FIRAuth.auth()?.currentUser == nil {
            
            handleLogout()
            
        } else {
            
            fetchEvents()
            
        }
        
    }
    //fetching the events from FireBase
    func fetchEvents() {
        //var that holds the type chosen from EventTypeView
        let type = eventTypeFetch as String
        
        //reference to the firebase database
        let fetchRef = FIRDatabase.database().reference(fromURL: "https://tambayan-ios-rey.firebaseio.com/")
        
        
        
        
        
        fetchRef.child("events").queryOrdered(byChild: "type").queryEqual(toValue: type).observe(.childAdded, with: { (snapshot) in
        
        //fetchRef.child("events").observe(.childAdded, with: { (snapshot) in
            
            //seeing if snapshot is empty, if not...putting the data into a dictionary
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let events = Events()
                //assigning the events parameters to events var of Events() type which is declared at the bottom of page
                events.title = dictionary["title"] as? String
                events.date = dictionary["date"] as? String
                events.image = dictionary["image"] as? String
                events.location = dictionary["location"] as? String
                events.price = dictionary["price"] as? String
                events.eventDescription = dictionary["description"] as? String
                events.type = dictionary["type"] as? String
                
                //if events.type == type {
                
                    uniVarEvents.append(events)
                    //image will be set immediately
                //}
                DispatchQueue.main.async(execute: {
                    
                    detailEvents = uniVarEvents
                    
                    self.tableView.reloadData()
                    
                    
                })
                    
            }
            
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //number of rows
        return uniVarEvents.count
        
    }

    //dunno why but I added self. and "unable to dequeue a cell with identifier Cell1 - must register a nib or a class for the identifier or connect a prototype cell in a storyboard." error fixed itself...
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventsViewCell
        
        let rowEvents = uniVarEvents[indexPath.row]//self.events[indexPath.row]

        cell.titleLabel.text = rowEvents.title
        //converting the unix timestamp that came from firebase database into ISO date
        if let unixTimestamp: String = rowEvents.date {
            
            
            let updateDate = TimeInterval(unixTimestamp) //converting the type from string to TimeInterval
            let celldate: Date              //declaring a var of type Date to recieve the result of conversion
            
            celldate = Date(timeIntervalSince1970: updateDate!)  //conversion back to Date type is done here
            
            //convering the date into a String so we can put it into labels
            let dateCell = DateFormatter.localizedString(from: celldate as Date, dateStyle: DateFormatter.Style.full, timeStyle: DateFormatter.Style.medium)
            
            //assinging the converted date to a global var for use in EventDetailsController
            detailDate = dateCell
            cell.subtitleLabel.text = dateCell
        }
        
        
        if let eventImage = rowEvents.image {
            
            cell.imageViewCell?.loadEventImageUsingCacheWithUrlString(urlString: eventImage)
            
        }

        return cell
    }
    //height of the cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
        
    }
    //saving the details of the event into global vars for use EventDetailsController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowEvents = detailEvents[indexPath.row]//self.events[indexPath.row]
        
        detailTitle = rowEvents.title
        //detailDate = rowEvents.date
        detailDescription = rowEvents.eventDescription
        detailLocation = rowEvents.location
        detailPrice = rowEvents.price
        detailImage = rowEvents.image

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //reloading the table everytime the EventsTableViewController appears
        uniVarEvents.removeAll()
        checkForUser()
        tableView.reloadData()
        
    }
 
}

//making a Events class with NSObject type with string variables inside. Its to be used to save retrived info from the Firebase database
class Events: NSObject {
    
    var title: String?
    var date: String?
    var image: String?
    var location: String?
    var price: String?
    var type: String?
    var eventDescription: String?
    
}

//caching the images so user doesnt download everytime the table reloads.

//declaring a private cache var
private var imageCache = NSCache<AnyObject, AnyObject>()
//this is an extension of UIImageView
extension UIImageView {
    //function to load the image using cache if cache is not empty
    func loadEventImageUsingCacheWithUrlString(urlString: String) {
        //clearing the imageView so wrong image doesnt blink on the imageView when scrolling up or down
        //smoothness
        self.image = nil
        //if cache is not empty, load image from cache
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            
            self.image = cacheImage
            return
            
        } else {
        //if cache is empty then download image from URL
            let url = NSURL(string: urlString)
            //downloading the image
            URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            
                if error != nil {
                
                    let err = error as! NSError
                    print(err)
                    return
                
                }
                //run the code below asynchronously(same time) as the main thread to load the images right away...smoothness
                DispatchQueue.main.async {
                    //data is assigned to a var of type UIImage
                    if let downloadedImage = UIImage(data: data!) {
                        //putting the image into imageCache also for later use
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        //loading the image to the imageView
                        self.image = downloadedImage
                    }
                
                }
            //resuming the app...have to or crash
            }).resume()
        
        }

    }

}










