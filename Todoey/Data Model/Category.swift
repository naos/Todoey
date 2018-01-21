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
    let items = List<Item>()
}
