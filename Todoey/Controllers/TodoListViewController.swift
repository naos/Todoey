//
//  ViewController.swift
//  Todoey
//
//  Created by Nikola Simić on 1/14/18.
//  Copyright © 2018 +ismo. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeholderDataTypeName = "items"
        placeholderCellBackgroundColorHexString = "FFFFFF"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        updateNavBar(withHexCode: "1D9BF6")
    }
    
    // MARK: - NavBar setup methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        let contrastNavBarColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.barTintColor = navBarColor
        navBar.tintColor = contrastNavBarColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : contrastNavBarColor]
        searchBar.barTintColor = navBarColor
    }
    
    // MARK: - TableView datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSourceIsEmpty ? 1 : todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if tableDataSourceIsEmpty {
            return cell
        }
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                let contrastColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = contrastColor
                cell.textLabel?.textColor = contrastColor
            }
            cell.accessoryType = item.done ? .checkmark : .none
        }
        return cell
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableDataSourceIsEmpty {
            tableView.deselectRow(at: indexPath, animated: true)
            addButtonPressed(navigationItem.rightBarButtonItem!)
        } else {
            if let item = todoItems?[indexPath.row] {
                do {
                    try realm.write {
                        item.done = !item.done
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
            }
            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            // Add function that performs input validation
            alertTextField.addTarget(self, action: #selector(self.alertTextFieldChanged), for: .editingChanged)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addItemAction = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = alert.textFields![0].text!
                        currentCategory.items.append(newItem)
                    }
                    self.tableDataSourceIsEmpty = self.todoItems!.isEmpty
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addAction(cancelAction)
        alert.addAction(addItemAction)
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
        // Perform input validation and enable Add Item button only when textField is not empty
        alert.actions[1].isEnabled = (alertTextField.text != "")
    }
    
    // MARK: - Model manipulation methods
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableDataSourceIsEmpty = todoItems!.isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
                tableDataSourceIsEmpty = todoItems!.isEmpty
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}

// MARK: - SearchBar delegate methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}

