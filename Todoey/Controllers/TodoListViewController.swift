//
//  ViewController.swift
//  Todoey
//
//  Created by fth on 30.08.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    let TODO_ITEM_ARRAY_KEY = "TodoItemArray"
    
    let realm = try! Realm()
    var todoItems : Results<TodoItem>?
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
     }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let todoItem = todoItems?[indexPath.row]{
            cell.textLabel?.text = todoItem.title
            cell.accessoryType = todoItem.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let todoItem = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    todoItem.done = !todoItem.done
                    //realm.delete(todoItem)
                }
            }catch{
                print("Error updating todo item : \(error)")
            }
        }
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        //saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
          
        if textField.text != "" {
            do {
                if let currentCategory = self.selectedCategory{
                    try self.realm.write {
                        let newTodoItem = TodoItem()
                        newTodoItem.title = textField.text!
                        newTodoItem.dateCreated = Date()
                        currentCategory.items.append(newTodoItem)
                    }
                }
                }catch{
                    print("Error saving todo item : \(error )")
                }
            }
            self.tableView.reloadData()
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
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

}
//MARK: - Search bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text)
            tableView.reloadData()
        }
    }

}
