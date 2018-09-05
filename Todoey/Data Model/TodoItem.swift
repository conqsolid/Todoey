//
//  Item.swift
//  Todoey
//
//  Created by fth on 30.08.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
