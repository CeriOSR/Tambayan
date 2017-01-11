//
//  AddEventsController.swift
//  Tambayan
//
//  Created by Rey Cerio on 2016-11-10.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class AddEventsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var eventImageStringURL = ""
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet var priceTextField: UITextField!
    
    @IBOutlet var locationTextField: UITextField!
    
    @IBOutlet var eventImage: UIImageView!
    
    @IBOutlet var eventDescriptionTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker?
    
    @IBOutlet weak var eventTypePicker: UIPickerView!
    //for the UIPickerView
    var eventTypeArray = ["Outdoors", "Music", "Education", "Technology"]
    
    var type = ""
    
    //alert Popup
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func handleSubmit(values: [String: AnyObject]) {
        
    
        let ref = FIRDatabase.database().reference(fromURL: "https://tambayan-ios-rey.firebaseio.com/")
        
        let eventDetailsRef = ref.child("events").childByAutoId()
        
        eventDetailsRef.updateChildValues(values) { (error, ref) in
            
            if let err = error as? NSError {
                
                self.createAlert(title: "Could Not Submit", message: String(describing: err))
                
            } else {
                
                self.performSegue(withIdentifier: "addEventsToEventsListSegue", sender: self)
                print("Event Submitted")
                
            }
            
        }
        
        
    }
    
    
    //Submitting the event into Firebase
    func submitEventImage() {
        //generating random imageName for the image with NSUUID().uuidString
        let imageName = NSUUID().uuidString
        //reference to Firebase Storage creating a child"eventImage" where we save the image with imageName
        let storageRef = FIRStorage.storage().reference().child("eventImage").child("\(imageName)")
        //chosenEventImage from ImagePicker func, uploadedImage = JPEG representation at 10% of its original (chosenEventImage)
        if let chosenEventImage = eventImage.image, let uploadedImage = UIImageJPEGRepresentation(chosenEventImage, 0.1) {
            //Storing the image into the database
            storageRef.put(uploadedImage, metadata: nil, completion: { (metaData, error) in
                
                if error != nil {
                    
                    self.createAlert(title: "Unable To Save Image", message: "Please try again.")
                    return
                }
                //saving the URL of the image and turning it into a string
                if let eventImageURL = metaData?.downloadURL()?.absoluteString {
                    
                    //assinging the string from URL into a global var for EventTableViewController display and eventDetailsController
                    self.eventImageStringURL = eventImageURL
                    self.submitEvent()
                    
                }
                
            })
            
        }
        
    }
    
    
    func submitEvent() {
        
        guard let title = self.titleTextField.text,
            let price = self.priceTextField.text,
            let location = self.locationTextField.text,
            let image = eventImageStringURL as String?,
            let description = self.eventDescriptionTextView.text,
            let eventType = type as String?
            
            
            
            //DateFormatter.localizedString(from: self.datePicker.date, dateStyle: .full, timeStyle: .short) as String?
            else {
                
                return
        }
        //turning the date into a Unix timestamp
        let myTimeStamp = self.datePicker?.date.timeIntervalSince1970
        
        
        //NEW BUG, 2017 IS NOT SAVED AS UNIX. WILL BE SAVED AS ISO.....SOLVE THIS MOTHAFUCKAZ!!!!
        var calendarDate: String! = ""
        //turning the unix timestamp into a string
        calendarDate =  String(describing: myTimeStamp!)
        
        
        let values = ["title": title, "price": price, "location": location, "image": image, "description": description, "date":
            calendarDate, "type": eventType]
        print([values])
        
        self.handleSubmit(values: values as [String: AnyObject])  //submitting the values into Firebase Database
        
        type = ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //dynamically adding the navigation Item submit on the right hand side...selector is the method to call
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(self.submitEventImage))
        //adding a Tap gesture recognizer on the image to select an image from Photo library
        eventImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectEventImage)))
        //initial value of PickerView
        type = eventTypeArray[0]
        
    }
    //declaring and launching the photo library image picker with an editor
    func handleSelectEventImage () {
        
        let picker = UIImagePickerController()
        //setting the delegate to self...must add UIImagePickerController to the class type
        picker.delegate = self
        //launching editor after picking
        picker.allowsEditing = true
        //presenting the picker
        present(picker, animated: true, completion: nil)
        
    }
    //handling what to do after picking the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker = UIImage()
        //seeing which image is available
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImageFromPicker = originalImage
            
        }
        //assignging the selected Image and posting it on the imageView
        if let selectedImage = selectedImageFromPicker as UIImage?{
            
            eventImage.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    //if you user press cancel, dismisses the controller and bring it back to the addEventsController window
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //PICKERVIEW!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return eventTypeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventTypeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        type = eventTypeArray[row]
    }
        
}
