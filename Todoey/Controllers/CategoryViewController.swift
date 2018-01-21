//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Nikola Simić on 1/19/18.
//  Copyright © 2018 +ismo. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    // MARK: - TableView datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        return cell
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Add new category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            // Add function that performs input validation
            alertTextField.addTarget(self, action: #selector(self.alertTextFieldChanged), for: .editingChanged)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addCategoryAction = UIAlertAction(title: "Add Category", style: .default) {
            (action) in
            // What will happen once the user clicks the Add Category button on our UIAlert
            let newCategory = Category()
            newCategory.name = alert.textFields![0].text!
            self.save(category: newCategory)
        }
        alert.addAction(cancelAction)
        alert.addAction(addCategoryAction)
        alert.actions[1].isEnabled = false
        present(alert, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldChanged(_ sender: Any) {
        let alertTextField = sender as! UITextField
        var responder: UIResponder! = alertTextField
        // Loop through the reponder chain until we find UIAlertController
        while !(responder is UIAlertController) {
            responder = responder.next
        }
        let alert = responder as! UIAlertController
        // Perform input validation and enable Add Category button only when textField is not empty
        alert.actions[1].isEnabled = (alertTextField.text != "")
    }
    
    // MARK: - Data manipulation methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}
