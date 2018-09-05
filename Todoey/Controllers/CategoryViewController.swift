//
//  CategoryViewController.swift
//  Todoey
//
//  Created by fth on 2.09.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    
    var categories : Results<Category>?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        if segue.identifier == "gotoItems"{
            let destinationVC = segue.destination as! TodoListViewController
        
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryItem", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        
        return cell
    }

    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField();
        let addCategoryAlert = UIAlertController(title: "", message: "Add Category", preferredStyle: .alert)
        let addCategoryAlertButton = UIAlertAction(title: "Add Category", style: .default) { (alertAction) in
            if textField.text != nil{
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.dateCreated = Date()
                self.save(category: newCategory)
            }
        }
        addCategoryAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        addCategoryAlert.addAction(addCategoryAlertButton)
        present(addCategoryAlert, animated: true,completion: nil)

    }
    
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
                tableView.reloadData()
            }
        }catch{
            print("Error saving categories : \(error)")
        }
     }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}

extension CategoryViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0){
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
