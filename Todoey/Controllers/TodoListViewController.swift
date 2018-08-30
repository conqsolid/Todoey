//
//  ViewController.swift
//  Todoey
//
//  Created by fth on 30.08.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    let TODO_ITEM_ARRAY_KEY = "TodoItemArray"
    
    var itemArray : [TodoItem] = []
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...100{
            let newItem = TodoItem()
            newItem.title = "abc"
            itemArray.append(newItem)
        }
        
        //defaults.set(itemArray, forKey: tod)
        
        if let items = defaults.array(forKey: TODO_ITEM_ARRAY_KEY) as? [TodoItem]{
            itemArray = items
        }
    }

    //MARK - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todoItem = itemArray[indexPath.row];
        cell.textLabel?.text = todoItem.title
        cell.accessoryType = todoItem.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if textField.text != "" {
                let newTodoItem = TodoItem()
                newTodoItem.title = textField.text!
                self.itemArray.append(newTodoItem)
                self.defaults.set(self.itemArray, forKey: self.TODO_ITEM_ARRAY_KEY)
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Todo Name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true,completion: nil)
    }
}

