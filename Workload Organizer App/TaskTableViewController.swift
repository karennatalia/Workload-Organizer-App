//
//  TaskTableViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var smallTaskArray = ["Small Task 1", "Small Task 2", "Small Task 3"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        smallTaskArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "smallTaskCell", for: indexPath) as! TodaysTaskCell

//        let cell = UITableViewCell()
        
        cell.taskTitleLabel.text = smallTaskArray[indexPath.section]

        return cell
    }
    
    
}

class TaskTableViewController: UITableViewController {

    @IBOutlet weak var smallTaskTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    var dataSource = DataSource()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: "CustomSectionHeaderUI", bundle: nil), forHeaderFooterViewReuseIdentifier: "CustomSectionHeader")
        smallTaskTableView.delegate = dataSource
        smallTaskTableView.dataSource = dataSource
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomSectionHeader") as! CustomSectionHeader
            
            header.headerTitle.text = "Divide into small task"
            header.addBtn.isHidden = true
            
            return header
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 40.0
        
        if section == 0 {
            height = 20.0
        }
        
        return height
    }

}
