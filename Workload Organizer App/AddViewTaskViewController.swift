//
//  AddViewTaskViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

class AddViewTaskViewController: UIViewController {

    @IBOutlet weak var smallTaskTableView: UITableView!
    
    var smallTaskArray = ["Small Task 1", "Small Task 2", "Small Task 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        smallTaskTableView.delegate = self
        smallTaskTableView.dataSource = self
    }

    @IBAction func addSmallTaskAction(_ sender: Any) {
    }
    
    @IBAction func addNewTaskAction(_ sender: Any) {
    }
}

extension AddViewTaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        smallTaskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = smallTaskTableView.dequeueReusableCell(withIdentifier: "smallTaskCell", for: indexPath) as! TodaysTaskCell
        
        cell.taskTitleLabel.text = smallTaskArray[indexPath.section]
        
        return cell
    }
    
    
}
