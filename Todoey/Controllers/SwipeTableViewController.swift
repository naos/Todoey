//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Nikola Simić on 1/21/18.
//  Copyright © 2018 +ismo. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var tableDataSourceIsEmpty = true
    var placeholderDataTypeName = "items"
    var placeholderCellBackgroundColorHexString = "1D9BF6"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        navigationController?.hidesNavigationBarHairline = true
        tableView.separatorStyle = .none
    }
    
    // MARK: - TableView datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        // Placeholder cell
        if tableDataSourceIsEmpty {
            cell.textLabel?.text = "Add \(placeholderDataTypeName)"
            cell.backgroundColor = UIColor(hexString: placeholderCellBackgroundColorHexString)
            cell.textLabel?.textColor = UIColor.gray
        }
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        if tableDataSourceIsEmpty {
            // If there are no items, don't add swipe actions to a placeholder cell.
            // There's no point in trying to delete it because it will automatically
            // disappear when items are added.
            return []
        } else {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") {
                (action, indexPath) in
                // Handle action by updating model with deletion
                self.updateModel(at: indexPath)
                self.tableView.beginUpdates()
                // If there are no data in the data source insert placeholder cell in the table
                if self.tableDataSourceIsEmpty {
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
                }
                // Trigger cell deletion manually
                action.fulfill(with: .delete)
                self.tableView.endUpdates()
            }
            // Customize the action appearance
            deleteAction.image = UIImage(named: "delete-icon")
            return [deleteAction]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        // Disable automatic triggering of deletion
        options.expansionStyle = .destructive(automaticallyDelete: false)
        //        options.transitionStyle = .border
        return options
    }
    
    // MARK: - TableView delegate methods
    
    func updateModel(at indexPath: IndexPath) {
        // Update our data model
    }
    
}
