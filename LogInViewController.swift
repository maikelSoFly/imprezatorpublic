//
//  LogInViewController.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import Firebase

protocol LogInDelegate {
    func pullData()
}

class LogInViewController: UIViewController {
    
    
    
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textBoxesContainer: UIView!
    
    var delegate:LogInDelegate?
    var loginSuccess = false
    
    
    @IBAction func actionButton(_ sender: UIButton) {
        self.delegate?.pullData()
        activityIndicator.startAnimating()
        let email = emailTextField?.text
        let password = passwordTextField?.text
        if email != nil && password != nil {
            Auth.auth().signIn(withEmail: email!, password: password!, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    let strErr = String(describing: error!)
                    if strErr.contains("ERROR_INVALID_EMAIL") {
                        self.errorMsgLabel.text = "Invalid e-mail address"
                    }
                    else if strErr.contains("ERROR_WRONG_PASSWORD") {
                        self.errorMsgLabel.text = "Invalid password"
                    }
                    
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                
                self.activityIndicator.stopAnimating()
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _  = self.view
        navigationController?.title = "Log in to Imprezator"
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        
        
        var constraints = [AnyObject]()
        
        // This constraint centers the imageView Horizontally in the screen
        constraints.append(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        NSLayoutConstraint.activate(constraints as! [NSLayoutConstraint])
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        errorMsgLabel.text = ""
        
        button.layer.cornerRadius = 25
        
        textBoxesContainer.layer.cornerRadius = 5
        
        emailTextField.layer.cornerRadius = 5
        emailTextField.placeholder = "Email address"
        
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.placeholder = "Password"
        
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTextField.frame.height))
        let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTextField.frame.height))
        
        
        emailTextField.leftView = paddingView2
        emailTextField.leftViewMode = UITextFieldViewMode.always
        
        passwordTextField.leftView = paddingView3
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        
        passwordTextField.isSecureTextEntry = true
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
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

