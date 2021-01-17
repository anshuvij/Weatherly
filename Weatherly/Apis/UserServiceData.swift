//
//  UserServiceData.swift
//  Weatherly
//
//  Created by Anshu Vij on 1/17/21.
//

import Foundation
import Firebase

protocol UserServiceDataDelegate {
    func getUserCoordinate(dictonary : Coordinate)
    func didFailToGetData()
}
class UserServiceData {
    
    var delegate : UserServiceDataDelegate?
    
    func fetchUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Constants.COLLECTION_USERS.document(uid).getDocument { (snapshots, error) in
            
            if snapshots?.data() != nil
            {
                let user  = Coordinate(dictonary: (snapshots?.data())!)
                self.delegate?.getUserCoordinate(dictonary: user)
            }
            else
            {
                self.delegate?.didFailToGetData()
            }
            
        }
    }
}
