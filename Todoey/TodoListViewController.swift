//
//  ViewController.swift
//  Todoey
//
//  Created by Nikola Simić on 1/14/18.
//  Copyright © 2018 +ismo. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = ["Find Mike", "Buy Eggs", "Destroy Demogorgon"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            // Add function that performs input validation
            alertTextField.addTarget(self, action: #selector(self.addNewItemTextFieldChanged), for: .editingChanged)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addItemAction = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            let newItem = alert.textFields![0].text!
            self.itemArray.append(newItem)
            self.tableView.reloadData()
        }
        alert.addAction(cancelAction)
        alert.addAction(addItemAction)
        alert.actions[1].isEnabled = false
        present(alert, animated: true, completion: nil)
    }
    
    @objc func addNewItemTextFieldChanged(_ sender: Any) {
        let alertTextField = sender as! UITextField
        var responder: UIResponder! = alertTextField
        // Loop through the reponder chain until we find UIAlertController
        while !(responder is UIAlertController) {
            responder = responder.next
        }
        let alert = responder as! UIAlertController
        // Perform input validation and enable Add Item button only when textField is not empty
        alert.actions[1].isEnabled = (alertTextField.text != "")
    }
}

