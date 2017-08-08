//
//  GuestTableViewController.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

extension GuestTableViewController: UISearchResultsUpdating, UISearchBarDelegate, CheckDelegate, LogInDelegate {
    func pullData() {
        
    }
    
    func didCheck() {
        setCheckedLabel();
    }
    
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

var checkedCounter: Int = 0
var events: [String: String] = [:]
var didLoggedOut = false
var currentEvent: Event!
var sellers: [String: Seller] = [:]



class GuestTableViewController: UITableViewController {
    
    var logInVC: LogInViewController? = nil
    @IBAction func handleEventsBtn(_ sender: Any) {
        performSegue(withIdentifier: "eventsSegue", sender: self)
    }
    
    @IBOutlet weak var checkedLabel: UILabel!
    @IBOutlet weak var eventButton: UIButton!
    
    
    var isSearching = false
    var filteredData = [Seller]()
    
    var isCellClosing = false
    
    let searchController = UISearchController(searchResultsController: nil)
    var resultController = UITableViewController()
    
    var ref: DatabaseReference!
    var loginSuccess = false
    
    
    
    @objc func setCheckedLabel() {
        self.checkedLabel.text = "Checked: \(checkedCounter) of \(sellers.count)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInVC = self.storyboard?.instantiateViewController(withIdentifier: "logInView") as? LogInViewController
        tableView.allowsSelection = false
        if Auth.auth().currentUser == nil {
            
            didLoggedOut = true
            presentLogInView()
        }
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.keyboardAppearance = .dark
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.barStyle = UIBarStyle.black
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        tableView.backgroundView = UIView()
        
        var contentOffset = tableView.contentOffset
        contentOffset.y += searchController.searchBar.frame.size.height
        tableView.contentOffset = contentOffset
        ref = Database.database().reference()
        fetchAvailableEvents()
        setCheckedLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeEvent), name: Notification.Name("eventChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchAvailableEvents), name: Notification.Name("eventAdded"), object: nil)
        
    }
    
    func presentLogInView() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "logInView") as! LogInViewController
        let _ = popoverContent.view
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.navigationBar.barStyle = UIBarStyle.black
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        
        popover?.delegate = self as? UIPopoverPresentationControllerDelegate
        popover?.sourceView = self.view
        
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
    @objc func changeEvent() {
        
        ref.database.reference().removeAllObservers()
        sellers.removeAll()
        checkedCounter = 0
        setCheckedLabel()
        self.title = currentEvent.name
        fetchAvailableEvents()
        fetchData(forEventID: currentEvent.key)
    }
    
    @objc func fetchAvailableEvents() {
        Database.database().reference().observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                if events.count == 0 {
                    currentEvent = Event(key: snapshot.key, name: dict["name"] as! String)
                    self.title = currentEvent.name
                    self.fetchData(forEventID: currentEvent.key)
                }
                events[snapshot.key] = dict["name"] as? String
                
            }
            
        }, withCancel: nil)
        
        Database.database().reference().observe(.childRemoved) { (snapshot) in
            events[snapshot.key] = nil
            if currentEvent.key == snapshot.key {
                currentEvent.key = ""
                currentEvent.name = ""
                self.title = "Select Event"
                self.ref.database.reference().removeAllObservers()
                sellers.removeAll()
                checkedCounter = 0
                self.setCheckedLabel()
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
        
        Database.database().reference().observe(.childChanged) { (snapshot) in
            if let dic = snapshot.value as? NSDictionary {
                events[snapshot.key] = dic["name"] as? String
                if currentEvent.key == snapshot.key {
                    currentEvent.name = (dic["name"] as? String)!
                    self.title = currentEvent.name
                }
                if !self.isCellClosing {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchData(forEventID eventID: String) {
        
        
        
        //When event is removed
        Database.database().reference().observe(.childRemoved, with: { (snapshot) in
            
            events[snapshot.key] = nil
            
        }, withCancel: nil)
        
        
        //When the seller is added
        Database.database().reference().child(eventID).child("sellers").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                
                
                let key = snapshot.key
                
                if let paymentDetails = value["paymentDetails"] as? [CFNumber : CFNumber], let email = value["email"] as? String, let isChecked = value["checked"] as? Bool, let sum = value["sum"] as? NSNumber  {
                    
                    let seller = Seller(email: email, name: email, sum: sum, isChecked: isChecked, paymentDetails: paymentDetails, key: key)
                    seller.timestamp = value["timestamp"] as! String
                    sellers[key] = seller
                    
                    
                    
                    if seller.isChecked {
                        
                        checkedCounter += 1
                    }
                    
                    self.setCheckedLabel()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        //When the seller is updated
        Database.database().reference().child(eventID).child("sellers").observe(.childChanged) { (snapshot) in
            
            let seller = sellers[snapshot.key]
            let wasChecked = seller?.isChecked
            
            //TODO: This needs to be changed!
            if let value = snapshot.value as? [String: AnyObject] {
                if let paymentDetails = value["paymentDetails"] as? [CFNumber : CFNumber], let email = value["email"] as? String, let isChecked = value["checked"] as? Bool, let sum = value["sum"] as? NSNumber, let timestamp = value["timestamp"] as? String  {
                    seller?.email = email
                    seller?.isChecked = isChecked
                    seller?.sum = sum
                    seller?.paymentDetails = paymentDetails
                    seller?.timestamp = timestamp
                }
            }
            
            if wasChecked! && !(seller?.isChecked)! {
                checkedCounter -= 1
            }
            else if !wasChecked! && (seller?.isChecked)! {
                checkedCounter += 1
            }
            if !self.isCellClosing {
                self.setCheckedLabel()
                self.tableView.reloadData()
            }
        }
        
        //When the seller is removed
        Database.database().reference().child(eventID).child("sellers").observe(.childRemoved) { (snapshot) in
            if snapshot.exists() {
                if sellers[snapshot.key] != nil && (sellers[snapshot.key]?.isChecked)! {
                    checkedCounter -= 1
                }
                sellers[snapshot.key] = nil
                
                self.setCheckedLabel()
                self.tableView.reloadData()
            }
        }
        
        //When participant is removed
        //        Database.database().reference().child(eventID).child("participants").observe(.childRemoved) { (snapshot) in
        //            if snapshot.exists() {
        //                guests[snapshot.key] = nil
        //                checkedCounter -= 1
        //                self.setCheckedLabel()
        //                self.tableView.reloadData()
        //                print(guests)
        //            }
        //        }
        
        //When participant is updated
        //        Database.database().reference().child(eventID).child("participants").observe(.childChanged) { (snapshot) in
        //            print("🍏\(snapshot.key) changed")
        //            let value = snapshot.value as? [String: AnyObject]
        //            print(value!)
        //            let guest = guests[snapshot.key]
        //            let wasChecked = guest?.isChecked
        //
        //            if let value = snapshot.value as? [String: AnyObject] {
        //                guest?.name = value["name"] as! String
        //                guest?.isChecked = value["checked"] as? Bool
        //                guest?.addedBy = value["addedBy"] as! String
        //                guest?.price = (value["price"] as! String)
        //            }
        //
        //            if wasChecked! && !(guest?.isChecked)! {
        //                checkedCounter -= 1
        //            }
        //            else if !wasChecked! && (guest?.isChecked)! {
        //                checkedCounter += 1
        //            }
        //            if !self.isCellClosing {
        //                self.setCheckedLabel()
        //                self.tableView.reloadData()
        //            }
        //
        //        }
        
        //When new participant is added
        //        Database.database().reference().child(eventID).child("participants").observe(.childAdded) { (snapshot) in
        //            if let dict = snapshot.value as? NSDictionary {
        //                let name = dict["name"] as! String
        //                let key = snapshot.key
        //                let addedBy = dict["addedBy"] as! String
        //                let price = (dict["price"] as! String)
        //                var isChecked = dict["checked"] as? Bool
        //                if isChecked == nil {
        //                    isChecked = false
        //                }
        //                let guest = Guest(name: name, withKey: key, from: addedBy, payed: price, isChecked: isChecked!)
        //
        //                guests[key] = guest
        //                if guest.isChecked! {
        //                    print("checked!!")
        //                    checkedCounter += 1
        //                }
        //
        //                self.setCheckedLabel()
        //                DispatchQueue.main.async {
        //                    self.tableView.reloadData()
        //                }
        //            }
        //        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        setCheckedLabel()
        if Auth.auth().currentUser != nil {
            
            //eventButton.isEnabled = true
            
            if didLoggedOut {
                ref.database.reference().removeAllObservers()
                fetchAvailableEvents()
                if currentEvent != nil {
                    fetchData(forEventID: currentEvent.key)
                }
                didLoggedOut = false
            }
        } else {
            
            //eventButton.isEnabled = false
            presentLogInView()
        }
        tableView.reloadData()
    }
    
    
    func filterContentForSearchText(searchText: String) {
        let sellersValues = Array(sellers.values)
        filteredData = sellersValues.filter { seller in
            let email = seller.email
            return email.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredData.count
        }
        return sellers.count
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : PaymentDetailsTableViewController = storyboard.instantiateViewController(withIdentifier: "paymentDetailsView") as! PaymentDetailsTableViewController
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        vc.test = cell.lblName.text!
        let seller = sellers[cell.key]
        vc.paymentDetails = (seller?.paymentDetails)!
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCell {
        
        let sellersValues = Array(sellers.values)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let seller: Seller
        if sellersValues.count > 0 {
            if searchController.isActive && searchController.searchBar.text != "" {
                seller = filteredData[indexPath.row]
            } else {
                
                seller = sellersValues[indexPath.row]
                
            }
            cell.configure(seller: seller)
            cell.key = seller.key
        }
        
        cell.checkBox.delegate = self
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let seller: Seller
        var isSearchingActive = false
        
        if searchController.isActive && searchController.searchBar.text != "" {
            seller = filteredData[indexPath.row]
            isSearchingActive = true
        }
        else {
            let sellersValues = Array(sellers.values)
            seller = sellersValues[indexPath.row]
        }
        
        if Auth.auth().currentUser != nil && (Auth.auth().currentUser?.email?.elementsEqual("organizacja@pieknasprawa.pl"))! {
            let check = UITableViewRowAction(style: .normal, title: "Check") { action, index in
                
                
                self.isCellClosing = true
                if !seller.isChecked {
                    seller.isChecked = true
                    checkedCounter += 1
                    self.setCheckedLabel()
                    
                    let post = ["checked": true,
                                "email": seller.email,
                                "paymentDetails" : seller.paymentDetails,
                                "sum": seller.sum,
                                "timestamp": seller.timestamp
                        ] as [String : Any]
                    
                    let childUpdate = ["/\(currentEvent.key)/sellers/\(seller.key)": post]
                    self.ref.updateChildValues(childUpdate)
                } else {
                    seller.isChecked = false
                    checkedCounter -= 1
                    self.setCheckedLabel()
                    let post = ["checked": false,
                                "email": seller.email,
                                "paymentDetails" : seller.paymentDetails,
                                "sum": seller.sum,
                                "timestamp": seller.timestamp
                        ] as [String : Any]
                    
                    let childUpdate = ["/\(currentEvent.key)/sellers/\(seller.key)": post]
                    self.ref.updateChildValues(childUpdate)
                }
                
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    tableView.reloadData()
                    self.isCellClosing = false
                })
                
                self.tableView.setEditing(false, animated: true)
                CATransaction.commit()
            }
            check.backgroundColor = UIColor.orange
            
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                self.tableView.setEditing(false, animated: true)
                self.ref.child(currentEvent.key).child("sellers").child(seller.key).removeValue()
                
                if isSearchingActive {
                    self.filteredData.remove(at: indexPath.row)
                }
                self.tableView.reloadData()
                
            }
            delete.backgroundColor = UIColor.red
            
            
            return [check, delete]
        }
        else if (Auth.auth().currentUser?.email?.elementsEqual(seller.email))! {
            
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                self.tableView.setEditing(false, animated: true)
                self.ref.child(currentEvent.key).child("sellers").child(seller.key).removeValue()
                
                if isSearchingActive {
                    self.filteredData.remove(at: indexPath.row)
                }
                self.tableView.reloadData()
                
            }
            delete.backgroundColor = UIColor.red
            
            return [delete]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        if sellers.count > 0 {
            let seller: Seller
            
            
            if searchController.isActive && searchController.searchBar.text != "" {
                seller = filteredData[indexPath.row]
                
            }
            else {
                let sellersValues = Array(sellers.values)
                seller = sellersValues[indexPath.row]
            }
            
            if Auth.auth().currentUser?.email == seller.email || Auth.auth().currentUser?.email == "organizacja@pieknasprawa.pl"{
                return true
            }
        }
        return false
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}

