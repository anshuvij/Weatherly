//
//  LoginViewController.swift
//  Weatherly
//
//  Created by Anshu Vij on 1/15/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
       // navigationController?.navigationBar.barStyle = .black

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func LoginPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text,let password = passwordTextfield.text
        {
            //[weak self]
            Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
                
               // guard let strongSelf = self else { return }
                if let e = error{
                    print(e.localizedDescription)
                }
                else
                {
                    self.performSegue(withIdentifier: Constants.loginSegue, sender: self)
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
