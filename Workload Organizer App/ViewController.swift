//
//  ViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 27/04/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var motivationLabel: UILabel!
    @IBOutlet weak var todaysTableView: UITableView!
    
    var todayTaskArray = ["Task 1", "Task 2", "Task 3"]
    var todaysTaskList: [SmallTask] = []
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todaysTableView.delegate = self
        todaysTableView.dataSource = self
        
        fetchSmallTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchSmallTasks()
        motivationLabel.text = "You only have \(todaysTaskList.count) tasks left today!"
        todaysTableView.reloadData()
    }
    
    func fetchSmallTasks() {
        do {
            let fetchSmallTask: NSFetchRequest<SmallTask> = SmallTask.fetchRequest()
             fetchSmallTask.predicate = NSPredicate(format: "assignToday = %d", 1)

            todaysTaskList = try! context.fetch(fetchSmallTask)
            DispatchQueue.main.async {
                self.todaysTableView.reloadData()
            }
        } catch {
            
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        todaysTaskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todaysTableView.dequeueReusableCell(withIdentifier: "todaysTaskCell", for: indexPath) as! TodaysTaskCell
    
        
        let task = todaysTaskList[indexPath.section]
        cell.taskTitleLabel.text = task.title
        cell.priorityLabel.text = task.priority
        cell.priorityLabel.backgroundColor = setTagColor(value: task.priority!)
        cell.difficultyLabel.text = task.difficulty
        cell.difficultyLabel.backgroundColor = setTagColor(value: task.difficulty!)
        
        return cell
    }
    
    func setTagColor(value: String) -> UIColor {
        let color: UIColor
        if value == "High Priority" || value == "Hard" {
            color = UIColor(named: "RedLevel")!
        }
        else if value == "Medium Priority" || value == "Medium" {
            color = UIColor(named: "YellowLevel")!
        }
        else {
            color = UIColor(named: "GreenLevel")!
        }
        return color
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let removedSmallTask = self.todaysTaskList[indexPath.section]
            
            self.context.delete(removedSmallTask)
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchSmallTasks()
            self.motivationLabel.text = "You only have \(self.todaysTaskList.count) tasks left today!"
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }

}

