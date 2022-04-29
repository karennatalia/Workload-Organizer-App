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
        
        if task.isDone == true {
            cell.checkMark.isHidden = false
            cell.checkMark.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        }
        else if task.isDone == false {
            cell.checkMark.isHidden = true
        }
        
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var action = UIContextualAction()
        if todaysTaskList[indexPath.section].isDone == false {
            action = UIContextualAction(style: .normal, title: "Finish") { (action, view, completionHandler) in
                let finishedSmallTask = self.todaysTaskList[indexPath.section]
                finishedSmallTask.isDone = true
                do {
                    try self.context.save()
                }
                catch {
                    
                }
                
                self.fetchSmallTasks()
            }
            action.backgroundColor = UIColor(named: "Green")
        }
        else {
            action = UIContextualAction(style: .normal, title: "Not Finish") { (action, view, completionHandler) in
                let finishedSmallTask = self.todaysTaskList[indexPath.section]
                finishedSmallTask.isDone = false
                do {
                    try self.context.save()
                }
                catch {
                    
                }
                
                self.fetchSmallTasks()
            }
            action.backgroundColor = UIColor(named: "Red")
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }

}

