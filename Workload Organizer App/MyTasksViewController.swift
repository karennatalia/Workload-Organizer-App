//
//  MyTasksViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

class MyTasksViewController: UIViewController {

    @IBOutlet weak var taskTableView: UITableView!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var taskList: [Task]?
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        fetchTasks()
    }
    
    func fetchTasks() {
        do {
            taskList = try context.fetch(Task.fetchRequest())
            DispatchQueue.main.async {
                self.taskTableView.reloadData()
            }
        } catch {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        fetchTasks()
        selectedIndex = -1
    }
    
    @IBAction func addTaskAction(_ sender: Any) {
        performSegue(withIdentifier: "toAddTaskSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddTaskSegue" {
            let dest = segue.destination as! AddViewTaskViewController
            if selectedIndex != -1 {
                dest.isViewing = true
                dest.selectedTask = taskList![selectedIndex]
                dest.selectedIndex = selectedIndex
                dest.delegate = self
            }
        }
    }
}

extension MyTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        taskList!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! MyTasksCell
        
        let task = self.taskList![indexPath.section]
        let progressNumber = getProgress(task: task)
        print("progress \(progressNumber)")
        
        cell.taskTitleLabel.text = task.title
        cell.dueDateLabel.text = Helper.formatDate(date: task.dueDate!)
        cell.progressBar.progress = Float(progressNumber)/100
        cell.percentageLabel.text = "\(Int(progressNumber))%"
        
        return cell
    }
    
    func getProgress(task: Task) -> Double {
        let smallTasks = task.smallTasks?.allObjects as! [SmallTask]
        var finished = 0.0
        
        for smallTask in smallTasks {
            if smallTask.isDone == true {
                finished += 1
            }
        }
        
        return (finished * 100) / Double(smallTasks.count)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let removedTask = self.taskList![indexPath.section]
            
            let smallTaskList = removedTask.smallTasks?.allObjects as! [SmallTask]
            
            for smallTask in smallTaskList {
                self.context.delete(smallTask)
            }
            
            self.context.delete(removedTask)
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchTasks()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.section
        performSegue(withIdentifier: "toAddTaskSegue", sender: self)
    }
}

extension MyTasksViewController: AddViewTaskViewControllerDelegate {
    func updateData(taskTitle: String, newDueDate: Date, progress: Int, smallTaskList: [SmallTask], updatedIndex:Int) {
        fetchTasks()
        let updatedTask = self.taskList![updatedIndex]
        updatedTask.title = taskTitle
        updatedTask.dueDate = newDueDate
        print(updatedIndex)
        updatedTask.progress = Int16(progress)
        
        for smallTask in smallTaskList {
            updatedTask.addToSmallTasks(smallTask)
        }
        do {
            try self.context.save()
        } catch {

        }
        self.fetchTasks()
    }
}
