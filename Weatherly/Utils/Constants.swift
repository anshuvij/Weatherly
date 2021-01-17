//
//  Constants.swift
//  Weatherly
//
//  Created by Anshu Vij on 1/15/21.
//

import Foundation
import Firebase

struct Constants {
    static let appName = "⚡️Weatherly"
    static let cellIdentifier = "ReusableCell"
    static let registerSegue = "RegisterToMap"
    static let loginSegue = "LoginToMap"
    static let viewControllerName = "ViewController"
    static let COLLECTION_USERS = Firestore.firestore().collection("users")
    static let base_url = "https://api.openweathermap.org/data/2.5/forecast?units=metric&appid=fc51a7af56a13ef4edac8997e95bdb12"
   
}
