//
//  ViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 27/04/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var motivationLabel: UILabel!
    @IBOutlet weak var todaysTableView: UITableView!
    
    var todayTaskArray = ["Task 1", "Task 2", "Task 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todaysTableView.delegate = self
        todaysTableView.dataSource = self
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        todayTaskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todaysTableView.dequeueReusableCell(withIdentifier: "todaysTaskCell", for: indexPath) as! TodaysTaskCell
        
        cell.taskTitleLabel.text = todayTaskArray[indexPath.section]
        cell.priorityLabel.backgroundColor = UIColor(named: "RedLevel")
        cell.difficultyLabel.backgroundColor = UIColor(named: "GreenLevel")
        
        return cell
    }
    

}

