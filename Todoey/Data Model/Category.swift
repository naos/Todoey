//
//  Category.swift
//  Todoey
//
//  Created by Nikola Simić on 1/20/18.
//  Copyright © 2018 +ismo. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var dateCreated: Date = Date()
    let items = List<Item>()
}
