//
//  ViewController.swift
//  API
//
//  Created by Nudzejma Kezo on 10/1/20.
//

import UIKit
import CoreData


@available(iOS 13.0, *)
class APITableViewController: UITableViewController, UITabBarDelegate{
    
    var vc: SearchTableViewContoller! = SearchTableViewContoller()
    @IBOutlet weak var searchbar: UISearchBar!
    
    var arrayLenght: Int = 0
    var lenght = 0
    var showSearch = true
    var page:Int = 1
    var listOfAPIObject = [APIObject](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationItem.title = "\(self.listOfAPIObject.count) APIs found"
            }
        }
    }
    //context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //global
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SearchData.plist")
    
    let defaults = UserDefaults.standard//save in memory 4ever
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MyCustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MyCustomCell")
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        searchbar.delegate = self
        vc.loadData()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewFunctionName"), object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch showSearch {
        case true:
            if vc.itemArray.count >= 10{
                return 10
            }
            else {
                return vc.itemArray.count
            }
        case false:
            return listOfAPIObject.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for:  indexPath) as! SearchTableViewCell
        if showSearch{
            arrayLenght = vc.itemArray.count - 1
            if vc.itemArray.count >= 10 {
                if lenght < 10 {
                    cell.textLabel?.text = vc.itemArray[arrayLenght - indexPath.row].name
                    lenght += 1
                }
            }
            else if vc.itemArray.count < 10 {
                cell.textLabel?.text = vc.itemArray[arrayLenght - indexPath.row].name
            }
           return cell
        }
        
        if !showSearch {
            lenght = 0
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell") as? MyCustomCell {
                let api = listOfAPIObject[indexPath.row]
                let nameString = api.poster_path
 
                cell.Title.text = "Title:\n\(api.title)"
                if nameString != nil {
                    let image = "https://image.tmdb.org/t/p/w92/\(nameString!)"
                    cell.imagePoster.load(urlString: image)
                }
                else{
                    cell.imagePoster.image = UIImage(named: "no-data")
                }
                if api.overview != "" {
                    cell.Overview.text = "\nOverview:\n\n\(String(describing: api.overview))"
                }
                else{
                    cell.Overview.text = "\nOverview:\n\nno data provided"
                }
                if api.release_date != "" {
                    cell.Date.text = "Release Date:\n\(String(describing: api.release_date))"
                }
                else{
                    cell.Date.text = "Release Date:\nno data provided"
                }
                return cell
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showSearch{
            showSearch = false
            page = 1
            listOfAPIObject.removeAll()
            searchbar.text = self.vc.itemArray[arrayLenght - indexPath.row].name!
            findSearch(searchbar.text!)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == listOfAPIObject.count {
            guard let searchbarText = searchbar.text else {return}
            findSearch(searchbarText)
        }
    }
    //getAPI
    func findSearch(_ searchbarText: String){
        vc.loadData()
        if page > 0 {
            let pageString:String = String(self.page)
            let replacedSearchBarText = String(searchbarText.map {
                $0 == " " ? "+" : $0
            })
            let request = APIRequest(movieName: replacedSearchBarText, page: pageString)
            request.getAPI{ [weak self] result in
            switch result{
            case .failure(_):
                if(self!.page == 1){
                            let when = DispatchTime.now()
                            DispatchQueue.main.asyncAfter(deadline: when){
                                let alert = UIAlertController(title: "Hey, we are sorry!", message: "There are no movies with that name", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                alert.dismiss(animated: true, completion: nil)
                                alert.view.layoutIfNeeded()
                                self!.present(alert, animated: true, completion: nil)
                            }
                }
                self!.page = 0
            case .success(let api):
                if !self!.vc.doExist(searchString: replacedSearchBarText){
                    let newItem = SearchData(context: self!.vc.context)
                    newItem.name = replacedSearchBarText
                    self!.vc.saveItems()
                }
                self?.listOfAPIObject += api
                self!.page += 1
                }
            }
        }
    }
}

@available(iOS 13.0, *)
extension APITableViewController : UISearchBarDelegate{
    func loadSearchData(){
        showSearch = true
        if showSearch {
            vc.loadData()
            vc.itemArray = vc.itemArray
        }
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadSearchData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
        showSearch = false
        page = 1
        listOfAPIObject.removeAll()
        
        guard let searchbarText = searchBar.text else {return}
        findSearch(searchbarText)
    }
}

