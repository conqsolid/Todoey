//
//  ViewController.swift
//  Todoey
//
//  Created by fth on 30.08.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    let TODO_ITEM_ARRAY_KEY = "TodoItemArray"
    
    var itemArray : [TodoItem] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todoItem = itemArray[indexPath.row];
        cell.textLabel?.text = todoItem.title
        cell.accessoryType = todoItem.done ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
          
            if textField.text != "" {
                let newTodoItem = TodoItem(context: self.context)
                newTodoItem.title = textField.text!
                newTodoItem.done = false
                newTodoItem.parentCategory = self.selectedCategory
                self.itemArray.append(newTodoItem)
                self.saveItems()
                self.loadItems()
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
    
    func saveItems(){
        do {
            try context.save()
        }catch{
            print("Error saving to context : \(error)")
        }
    }
    
    
    func loadItems(with request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), predicate: NSPredicate? = nil ){
        do{
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            
            if let previousPredicate = predicate{
                request.predicate =  NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, previousPredicate])
            }else{
                request.predicate = categoryPredicate
            }
            
            itemArray = try context.fetch(request)
            tableView.reloadData()
        }catch{
            print("Error fetching todolist : \(error)")
        }
    }

}
//MARK: - Search bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest = TodoItem.fetchRequest()
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: titlePredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
