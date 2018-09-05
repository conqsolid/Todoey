//
//  AppDelegate.swift
//  Todoey
//
//  Created by fth on 30.08.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
        do{
            _ = try Realm()
        }catch{
            print("Error initialization new Realm : \(error)")
        }
        
        return true
    }
    
}

