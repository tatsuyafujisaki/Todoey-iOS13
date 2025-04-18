//
//  Category.swift
//  Todoey
//
//  Created by Tatsuya Fujisaki on 2025/04/18.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
