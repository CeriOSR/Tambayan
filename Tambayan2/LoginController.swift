//
//  ViewController.swift
//  Tambayan
//
//  Created by Rey Cerio on 2016-11-09.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!

    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginRegisterSegmentControl: UISegmentedControl!
    
    @IBOutlet var loginRegisterButton: UIButton!
    
    //hide username if on Login mode and change title of LoginRegister button depending on which mode
    @IBAction func loginRegisterSC(_ sender: AnyObject) {
        
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState.normal)
        
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            
            usernameTextField.isHidden = true
            
        } else {
            
            usernameTextField.isHidden = false

        }

        
    }
    
    //call the handleLoginRegister func
    @IBAction func loginRegister(_ sender: AnyObject) {
        
        //self.performSegue(withIdentifier: "showEventsTableViewController", sender: self)
        handleLoginRegister()
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
        if (FBSDKAccessToken.current() != nil) {
            
            performSegue(withIdentifier: "loginToEventTypeSegue", sender: self)
            
        } else {
            
            let fbLoginButton = FBSDKLoginButton()
            fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(fbLoginButton)
            
            fbLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            fbLoginButton.topAnchor.constraint(equalTo: self.loginRegisterButton.bottomAnchor, constant: 200).isActive = true
            
            fbLoginButton.readPermissions = ["public_profile", "email"] //add friends list if you want
            
            fbLoginButton.delegate = self
            
            
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return.lightContent
        
    }
    
    //alert Popup
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

    //calls the login or register func depending on mode.
    func handleLoginRegister() {
        
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            
            handleLogin()
            
        } else {
            
            handleRegister()
            
        }
        
    }
    //login mode
    func handleLogin() {
        //guard is error handling to see if any field is empty
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            //if any is invalid then alert and just return to where it is currently.
            createAlert(title: "Form Invalid", message: "Email and Password required.")
            return
        }
        //signing user in using email and password
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error as? NSError {
                
                
                self.createAlert(title: "Unable to Login", message: String(describing: error))
                return
                
            }
            
            //successfully logged in user go to EventsTableViewController
            self.performSegue(withIdentifier: "loginToEventTypeSegue", sender: self)
            print("USER LOGGED IN!!!!")
            
        })
        
    }
    //register mode
    func handleRegister() {
        //guard to error handle if textFields are empty or invalid
        guard let name = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            createAlert(title: "Form Invalid", message: "Email and Password required")
            return
        }
        //creating a user in the Firebase Auth
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                self.createAlert(title: "Unable to Register", message: "Invalid email or password.")
                
            }
            //getting the user ID and saving it to a var for use
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let values = ["name": name, "email": email, "password": password]
            //writing the user into the database with their user ID
            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
            print("USER REGISTERED!!!!")

        })
        
    }
    
    //writing into database
    func registerUserIntoDatabaseWithUID(uid: String, values: [
        String: AnyObject]) {
        //reference to database first
        let ref = FIRDatabase.database().reference(fromURL: "https://tambayan-ios-rey.firebaseio.com/")
        //creating a child where we save the users
        let userReference = ref.child("users").child(uid)
        //writing into the child
        userReference.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                self.createAlert(title: "Connection Error", message: "Try again later.")
                
            }
            //if no error then perform segue into EventsTableViewController
            self.performSegue(withIdentifier: "loginToEventTypeSegue", sender: self)
            
        }
        
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print (error!.localizedDescription)
            return
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            
            if error != nil {
                
                print(error!.localizedDescription)
                return
                
            }
            self.performSegue(withIdentifier: "loginToEventTypeSegue", sender: self)
            print("User Logged In With Facebook!!!")
            
        })
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
        print("User Logged Out Of Facebook!!!")
        
    }


}


/*   ****MANUAL FACEBOOK LOG IN****
 
 
//2 methods needed by FBloginbutton
func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    
    if error != nil {
        
        createAlert(title: "Unable To Login", message: "Please try again!")
        
    } else if result.isCancelled {
        
        print("User Cancelled Login")
        
    } else {
        
        if result.grantedPermissions.contains("email") {
            //facebook graph contains all the data about the user
            if let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"]){
                //start the graph request
                graphRequest.start(completionHandler: { (connection, result, error) in
                    
                    
                    if error != nil {
                        
                        print(error ?? "Graph Request Failed!")
                        
                    } else {
                        
                        if let userDetails = result as? [String: String] {
                            
                            let fbEmail = userDetails["email"]!
                            let fbName = userDetails["name"]!
                            let fbId = userDetails["id"]!
                            
                            FIRAuth.auth()?.signIn(withEmail: fbEmail, password: "password", completion: { (user, error) in
                                
                                if let error = error as? NSError {
                                    
                                    if error.code == 17011 {
                                        
                                        //creating a user in the Firebase Auth
                                        FIRAuth.auth()?.createUser(withEmail: fbEmail, password: "password", completion: { (user, error) in
                                            
                                            if error != nil {
                                                
                                                self.createAlert(title: "Unable to Register", message: "Invalid email or password.")
                                                
                                            }
                                            
                                            //successfully authenticated user
                                            let values = ["name": fbName, "email": fbEmail, "password": "password"]
                                            //writing the user into the database with their user ID
                                            self.registerUserIntoDatabaseWithUID(uid: fbId, values: values as [String : AnyObject])
                                            print("USER REGISTERED!!!!")
                                            
                                        })
                                        
                                        
                                    } else {
                                        
                                        self.createAlert(title: "Unable to Login", message: String(describing: error))
                                        return
                                        
                                    }
                                    
                                } else {
                                    
                                    //successfully logged in user go to EventsTableViewController
                                    self.performSegue(withIdentifier: "loginToEventTypeSegue", sender: self)
                                    print("USER LOGGED IN!!!!")
                                    
                                }
                                
                            })
                            
                            
                        }
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
}
//facebook log out
func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    
    print("Logged OUT!!!")
    
}
*/


