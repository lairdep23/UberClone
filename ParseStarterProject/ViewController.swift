/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

//parse-dashboard --appId uberclone15 --masterKey 152489152489 --serverURL "http://uberclone15.herokuapp.com/parse" --appName uberclone15

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var toggleSignUpButton: UIButton!
    
    var signUpState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.delegate = self
        password.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func signUp(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Missing Field(s)", message: "Please enter a full username and password")
            
        } else {
            
            
            
            
            
            if signUpState == true {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                user["isDriver"] = `switch`.on
            
                user.signUpInBackgroundWithBlock {
                    (succeeded, error) -> Void in
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? String {
                    
                            self.displayAlert("Sign Up Failed", message: errorString)
                        
                        }
                    } else {
                    
                        print("successful Sign up")
                    }
                    
                }
                
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text! , password: password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil {
                        
                        print("Successful Login")
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            self.displayAlert("Login Failed", message: errorString)
                        }
                    }
                }
                
            }
        }
        
    }
    
    
    @IBAction func toggleSignUp(sender: AnyObject) {
        
        if signUpState == true {
            
            signUpButton.setTitle("Login", forState: UIControlState.Normal)
            
            toggleSignUpButton.setTitle("Switch to Sign Up", forState: UIControlState.Normal)
            
            signUpState = false
            
            riderLabel.hidden = true
            driverLabel.hidden = true
            `switch`.hidden = true
            
        } else {
            
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            toggleSignUpButton.setTitle("Switch to Login", forState: UIControlState.Normal)
            
            signUpState = true
            
            riderLabel.hidden = false
            driverLabel.hidden = false
            `switch`.hidden = false
            
            
        }
        
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}












