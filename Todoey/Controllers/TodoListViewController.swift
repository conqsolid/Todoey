//
//  ViewController.swift
//  Todoey
//
//  Created by fth on 30.08.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    let TODO_ITEM_ARRAY_KEY = "TodoItemArray"
    
    let realm = try! Realm()
    var todoItems : Results<TodoItem>?
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
     }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.backColor else {fatalError()}
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Navigation Bar Setup
    
    func updateNavBar(withHexCode colorHexCode : String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        searchBar.barTintColor = navBarColor
        navBar.barTintColor = navBarColor
        navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : navBar.tintColor]
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
        if let todoItem = todoItems?[indexPath.row]{
            cell.textLabel?.text = todoItem.title
            cell.accessoryType = todoItem.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.backColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            }
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
        let addItemAlert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
          
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
        
        addItemAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Todo Name"
            textField = alertTextField
        }
        
        addItemAlert.addAction(addAction)
        addItemAlert.addAction(cancelAction)
        present(addItemAlert, animated: true,completion: nil)
    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        do{
            if let tobeDeletedItem = self.todoItems?[indexPath.row]{
                try self.realm.write {
                    self.realm.delete(tobeDeletedItem)
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("Error while deleting : \(error)")
        }
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

