//
//  CategoryViewController.swift
//  Todoey
//
//  Created by fth on 2.09.2018.
//  Copyright © 2018 Conqsolid. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories : [Category] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        if segue.identifier == "gotoItems"{
            let destinationVC = segue.destination as! TodoListViewController
        
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categories[indexPath.row]
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryItem", for: indexPath)
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }

    func loadCategories(with request:  NSFetchRequest<Category> = Category.fetchRequest()){
        do {
            categories = try context.fetch(request)
            tableView.reloadData()
        }catch{
            print("Error fetching categories : \(error)")
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField();
        let addCategoryAlert = UIAlertController(title: "Add Item", message: "Add Category", preferredStyle: .alert)
        let addCategoryAlertButton = UIAlertAction(title: "Add Category", style: .default) { (alertAction) in
            if textField.text != nil{
                let category = Category(context: self.context)
                category.name = textField.text
                self.categories.append(category)
                self.saveCategories()
                self.loadCategories()
            }
        }
        addCategoryAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        addCategoryAlert.addAction(addCategoryAlertButton)
        present(addCategoryAlert, animated: true,completion: nil)

    }
    
    func saveCategories(){
        do{
            try context.save()
        }catch{
            print("Error saving categories : \(error)")
        }
     }
}

extension CategoryViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadCategories(with: request)
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
