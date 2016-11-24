//
//  EventDetailsController.swift
//  Tambayan
//
//  Created by Rey Cerio on 2016-11-12.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import EventKit
import EventKitUI

class EventDetailsController: UIViewController {
    
    //create a calendar
    var calendar: EKCalendar!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var eventImageView: UIImageView!

    @IBOutlet var locationLabel: UILabel!
    
    @IBAction func addToCalendar(_ sender: Any) {
        
        addEventToCalendar()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //adding a button on the right side of the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calendar", style: .plain, target: self, action: #selector(addEventToCalendar))
        locationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMap)))
        
        titleLabel.text = detailTitle
        
        descriptionTextView.text = detailDescription
        
        dateLabel.text = detailDate
        
        priceLabel.text = detailPrice
        
        locationLabel.text = detailLocation
        
        
        //loading an image into the imageView
        if let cellImage = detailImage! as String?{
            //fetching image via cache func for the imageView
            eventImageView.loadEventImageUsingCacheWithUrlString(urlString: cellImage)
         
        }
        
        
    }
    //creating an event function for the calendar with parameters Title, startDate and endDate must Import EventKit
    func createEvent(eventStore: EKEventStore, title: String, startDate: Date, endDate: Date){
        //creating an event of type EKEvent from eventStore
        let event = EKEvent(eventStore: eventStore)
        
        event.title = detailTitle!
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        //saving the event into the calendar
        do {
            try eventStore.save(event, span: EKSpan.thisEvent)
        } catch {
            
            createAlert(title: "Event Cannot Be Saved!", message: "Please try again!")
        }
        
    }
    //adding the event to the calendar
    func addEventToCalendar(){
        
        //create an eventstore
        //detailDate is in Unix Timestamp
        let calendarDate = detailDate
        //creating a dateFormatter to convert the unix into ISO
        let dateformatter = DateFormatter()
        //the format we want the result to be for posting to calendar...IT HAS TO BE EXACTLY THE SAME AS THE CONVERTED UNIX ELSE IT WILL CRASH
        dateformatter.dateFormat = "EEEE, MMMM dd, yyyy' at 'h:mm:ss a"
        //converting Unix to ISO and assigning the result to a variable
        let strDate = dateformatter.date(from: calendarDate!)
        
        print(strDate!)
        //assinging the converted date to startDate of calendar
        let startDate = strDate
        //adding an hour to the start date
        let endDate = startDate?.addingTimeInterval(60 * 60) // One hour
        //creating an event store to store your event into calendar
        let eventStore = EKEventStore()
        //checking for authorization from user
        if (EKEventStore.authorizationStatus(for: EKEntityType.event) != EKAuthorizationStatus.authorized) {
            
            eventStore.requestAccess(to: EKEntityType.event, completion: { (granted, error) in
                
                if error != nil {
                    
                    self.createAlert(title: "Event Cannot Be Saved!", message: "Please try again!")
                    
                } else {
                    //if auth granted calling the createEvent which adds event into calendar
                    self.createEvent(eventStore: eventStore, title: detailTitle!, startDate: startDate!, endDate: endDate!)
                    
                }
                
            })
            
        } else {
            //if already authorized then call the createEvent which adds event into calendar
            self.createEvent(eventStore: eventStore, title: detailTitle!, startDate: startDate!, endDate: endDate!)

            
        }
        
    }
    
    //alert Popup
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

    //Opening the address in maps.google by tapping on location //via SEARCH FUNC of maps.google
    func openMap() {
        
        let baseUrl : String = "http://maps.google.com/?q="
        let name = detailLocation
        //replacing % to all unallowed characters like spaces
        let encodedName = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let finalUrl = baseUrl + encodedName!
        
        let url = NSURL(string: finalUrl)!
        //navigating to maps.google.com with the url
        UIApplication.shared.openURL(url as URL)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }
    
}

/*
import UIKit
import EventKit

class ViewController: UIViewController {
    
    var savedEventId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Creates an event in the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            savedEventId = event.eventIdentifier
        } catch {
            print("Bad things happened")
        }
    }
    
    // Removes an event from the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func deleteEvent(eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.eventWithIdentifier(eventIdentifier)
        if (eventToRemove != nil) {
            do {
                try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
            } catch {
                print("Bad things happened")
            }
        }
    }
    
    // Responds to button to add event. This checks that we have permission first, before adding the
    // event
    @IBAction func addEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        
        let startDate = NSDate()
        let endDate = startDate.dateByAddingTimeInterval(60 * 60) // One hour
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                self.createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
        }
    }
    
    
    // Responds to button to remove event. This checks that we have permission first, before removing the
    // event
    @IBAction func removeEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: { (granted, error) -> Void in
                self.deleteEvent(eventStore, eventIdentifier: self.savedEventId)
            })
        } else {
            deleteEvent(eventStore, eventIdentifier: savedEventId)
        }
        
    }
}
*/
