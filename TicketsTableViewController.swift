//
//  TicketsTableViewController.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

extension TicketsTableViewController: TicketsCellDelegate {
    func editingDidEnd() {
        self.title = "Tickets for \(sumGainFromTickets()) PLN"
    }
    
    func setPrice(price: Double, cell: TicketsTableViewCell) {
    }
    
    func setQuantity(quantity: Int, cell: TicketsTableViewCell) {
        
    }
    
    
    
}

class TicketsTableViewController: UITableViewController {
    var tickets: [Tickets] = []
    var summaryGain: Double = 0
    
    
    
    
    @IBAction func saveView(_ sender: UIBarButtonItem) {
        if tickets.count == 0 {
            let alertController = UIAlertController(title: "Error", message: "No data to save", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if currentEvent == nil || currentEvent.key == "" || currentEvent.name == "" {
            let alertController = UIAlertController(title: "Error", message: "Event is not selected", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
            
        else if checkIfCellsAreFilled() {
            
            var ticketsDic:[String : Int] = [:]
            var sellerDic:[String : Any] = [:]
            tickets.forEach { (ticket) in
                ticketsDic[String(ticket.price)] = ticket.quantity
            }
            let sum = sumGainFromTickets()
            let timestamp = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
            let email = Auth.auth().currentUser?.email
            let isChecked: Bool = false
            let uuid = UUID().uuidString
            
            sellerDic["checked"] = isChecked
            sellerDic["email"] = email
            sellerDic["paymentDetails"] = ticketsDic
            sellerDic["sum"] = sum
            sellerDic["timestamp"] = timestamp as String
            
            
            Database.database().reference().child(currentEvent.key).child("sellers").child(uuid).setValue(sellerDic)
            navigationController?.popToRootViewController(animated: true)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Some cells are not filled", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleBtnAddCell(_ sender: UIButton) {
        let stack = Tickets(price: 0, quantity: 0)
        tickets.append(stack)
        tableView.reloadData()
    }
    @IBOutlet weak var btnAdd: UIButton!
    
    var cellsAmount: Int = 1
    var cellsSpacing: CGFloat = 10
    
    func checkIfCellsAreFilled() -> Bool {
        
        var isOk = true
        tickets.forEach { (ticket) in
            if ticket.price == 0 || ticket.quantity == 0 {
                isOk = false
            }
        }
        return isOk
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAdd.layer.cornerRadius = btnAdd.frame.width/2
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsWhenKeyboardAppears = true
        
        var constraints = [AnyObject]()
        
        // This constraint centers the imageView Horizontally in the screen
        constraints.append(NSLayoutConstraint(item: btnAdd, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        NSLayoutConstraint.activate(constraints as! [NSLayoutConstraint])
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //self.tableView.register(TicketsTableViewCell.self, forCellReuseIdentifier: "TicketsCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        let stack = Tickets(price: 0, quantity: 0)
        tickets.append(stack)
        self.title = "Tickets"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sumGainFromTickets() -> Int {
        var sum: Int = 0
        tickets.forEach { stack in
            sum += (stack.price * stack.quantity)
        }
        return sum
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tickets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return cellsSpacing*4
        }
        
        return cellsSpacing
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellsSpacing
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsCell", for: indexPath) as! TicketsTableViewCell
        
        //        cell.layer.borderColor = UIColor.black.cgColor
        //        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        cell.configure(tickets: tickets[indexPath.section])
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.tickets.remove(at: indexPath.section)
            tableView.reloadData()
            self.title = "Tickets for \(self.sumGainFromTickets()) PLN"
        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
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

