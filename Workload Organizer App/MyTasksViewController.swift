//
//  MyTasksViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

class MyTasksViewController: UIViewController {

    @IBOutlet weak var taskTableView: UITableView!
    
    var taskArray = ["Task Dummy 1", "Task Dummy 2", "Task Dummy 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskTableView.delegate = self
        taskTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func addTaskAction(_ sender: Any) {
        performSegue(withIdentifier: "toAddTaskSegue", sender: self)
    }
    
}

extension MyTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        taskArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! MyTasksCell
        
        cell.taskTitleLabel.text = taskArray[indexPath.section]
        
        return cell
    }
}
