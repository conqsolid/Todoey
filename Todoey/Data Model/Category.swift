//
//  Category.swift
//  Todoey
//
//  Created by fth on 4.09.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var dateCreated : Date?
    @objc dynamic var backColor : String?
    let items = List<TodoItem>()
    
}
