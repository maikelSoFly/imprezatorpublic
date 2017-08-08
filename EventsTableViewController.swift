//
//  EventsTableViewController.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EventsTableViewController: UITableViewController {
    
    var isCellClosing = false
    
    @IBAction func handleAddBtn(_ sender: UIBarButtonItem) {
        if (Auth.auth().currentUser?.email?.elementsEqual("organizacja@pieknasprawa.pl"))! {
            let alertController = UIAlertController(title: "Add New Event", message: "Enter event name", preferredStyle: .alert)
            
            
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                alert -> Void in
                
                let firstTextField = alertController.textFields![0] as UITextField
                if firstTextField.text != "" {
                    //TODO adding a new event to database
                    let name = firstTextField.text
                    var value: [String : Any] = [:]
                    value["name"] = name
                    let uuid = "event" + UUID().uuidString
                    events[uuid] = name
                    Database.database().reference().child(uuid).setValue(value)
                    
                    NotificationCenter.default.post(name: Notification.Name("eventAdded"), object: nil)
                    self.tableView.reloadData()
                } else {
                    
                }
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in
                //self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Event name"
                
            }
            
            
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Denied", message: "You do not have permission to add a new event", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func fetchAvailableEvents() {
        Database.database().reference().observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? NSDictionary {
                if events.count == 0 {
                    currentEvent = Event(key: snapshot.key, name: dict["name"] as! String)
                    self.title = currentEvent.name
                }
                events[snapshot.key] = dict["name"] as? String
                
            }
            
            self.tableView.reloadData()
            
        }, withCancel: nil)
        
        Database.database().reference().observe(.childRemoved) { (snapshot) in
            events[snapshot.key] = nil
            if !self.isCellClosing {
                self.tableView.reloadData()
            }
        }
        
        Database.database().reference().observe(.childChanged) { (snapshot) in
            if let dic = snapshot.value as? NSDictionary {
                events[snapshot.key] = dic["name"] as? String
                if !self.isCellClosing {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
        //navigationController?.hidesBarsWhenKeyboardAppears = true
        fetchAvailableEvents()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EventTableViewCell {
        let eventsKeys = Array(events.keys)
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        let key = eventsKeys[indexPath.row]
        let name = events[key]
        cell.textLabel?.text = name
        cell.configure(key: key, name: name!)
        cell.textLabel?.textColor = UIColor.white
        if currentEvent == nil {
            if indexPath.row == 0 {
                cell.accessoryType = .checkmark
                currentEvent.key = cell.key
                currentEvent.name = cell.name
                NotificationCenter.default.post(name: Notification.Name("eventChanged"), object: nil)
            } else {
                cell.accessoryType = .none
            }
        } else {
            if cell.key == currentEvent.key {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! EventTableViewCell
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            for i in 0..<tableView.numberOfRows(inSection: 0) {
                tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .none
                
            }
            cell.accessoryType = .checkmark
            
            currentEvent.key = cell.key
            currentEvent.name = cell.name
            NotificationCenter.default.post(name: Notification.Name("eventChanged"), object: nil)
        } else {
            
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if Auth.auth().currentUser != nil && (Auth.auth().currentUser?.email?.elementsEqual("organizacja@pieknasprawa.pl"))! {
            self.isCellClosing = true
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell
                
                Database.database().reference().child((cell?.key)!).removeValue()
                events[(cell?.key)!] = nil
                
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    tableView.reloadData()
                    self.isCellClosing = false
                })
                
                self.tableView.setEditing(false, animated: true)
                CATransaction.commit()
                
            }
            delete.backgroundColor = UIColor.red
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, index) in
                self.isCellClosing = true
                let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell
                let alertController = UIAlertController(title: "Rename", message: "Rename event @\(cell?.name ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                    alert -> Void in
                    
                    let newName = alertController.textFields![0].text
                    
                    //TODO
                    if newName != "" {
                        Database.database().reference().child((cell?.key)!).updateChildValues(["name" : newName!])
                    }
                    
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        tableView.reloadData()
                        self.isCellClosing = false
                    })
                    
                    self.tableView.setEditing(false, animated: true)
                    CATransaction.commit()
                    
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "New event name"
                }
                
                
                alertController.addAction(saveAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
            
            return [delete, edit]
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        if Auth.auth().currentUser != nil && (Auth.auth().currentUser?.email?.elementsEqual("organizacja@pieknasprawa.pl"))! {
            return true
        }
        return false
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

