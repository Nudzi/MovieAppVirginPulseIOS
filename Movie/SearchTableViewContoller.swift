//
//  ViewController.swift
//  TODO
//
//  Created by Nudzejma Kezo on 9/29/20.
//

import UIKit
import CoreData

@available(iOS 13.0, *)
class SearchTableViewContoller: UITableViewController {

    var itemArray = [SearchData]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //global
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SearchData.plist")
    
    let defaults = UserDefaults.standard//save in memory 4ever
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData), name: Notification.Name("NewFunctionName"), object: nil)
        loadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].name//showing title prop
        return cell
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
    }
    
    @objc func loadData() {
        let request : NSFetchRequest<SearchData> = SearchData.fetchRequest()//must specify
        do{
        itemArray = try context.fetch(request)
            self.tableView.reloadData()
        }catch{
            print("Error fetching")
        }
    }
    
    func doExist(searchString: String) -> Bool{
        for item in itemArray {
            if item.name! == searchString{
                return true
            }
        }
        return false
    }
}
