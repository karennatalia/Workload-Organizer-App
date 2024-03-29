//
//  AddViewTaskViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit
import CoreData

protocol AddViewTaskViewControllerDelegate: AnyObject {
    func updateData(taskTitle:String, newDueDate:Date, progress:Int, smallTaskList:[SmallTask], updatedIndex:Int)
}

class AddViewTaskViewController: UIViewController {
    
    @IBOutlet weak var titlePage: UILabel!
    @IBOutlet weak var taskTitleField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var smallTaskTableView: UITableView!
    @IBOutlet weak var rightActionBtn: UIButton!

    var smallTaskList: [SmallTask] = []
    var isViewing = false
    var selectedTask: Task?
    var selectedIndex = -1
    var selectedSmallTaskIndex = -1
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate:AddViewTaskViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction(sender:)))
        
        smallTaskTableView.delegate = self
        smallTaskTableView.dataSource = self
        
        titlePage.text = "Add New Task"
        setButtonStyle(titleText: "Add Task", colorName: "Red")
        
        if isViewing == true {
            titlePage.text = "Task"
            taskTitleField.text = selectedTask?.title
            dueDatePicker.date = (selectedTask?.dueDate)!
            smallTaskList = selectedTask?.smallTasks?.allObjects as! [SmallTask]
            rightActionBtn.isHidden = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        selectedSmallTaskIndex = -1
        fetchSmallTasks()
    }
    
    func setButtonStyle(titleText: String, colorName: String) {
        rightActionBtn.layer.cornerRadius = 5.0
        rightActionBtn.setTitleColor(UIColor.white, for: .normal)
        rightActionBtn.backgroundColor = UIColor(named: colorName)
        rightActionBtn.setTitle(titleText, for: .normal)
    }
    
    @objc func backAction(sender: UIBarButtonItem) {
        print("back clicked")
        if isViewing == true {  // save
            if taskTitleField.text?.isEmpty == true {
                Helper.showAlert(title: "Task Name Required", message: "You need to give the task a name", over: self)
            }
            else if smallTaskList.count == 0 {
                Helper.showAlert(title: "Minimum 1 Small Task Required", message: "You need to add minimum 1 small task to be able to create a task", over: self)
            }
            else {
                delegate?.updateData(taskTitle: taskTitleField.text!, newDueDate: dueDatePicker.date, progress: 50, smallTaskList: smallTaskList, updatedIndex: selectedIndex)
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func fetchSmallTasks() {
        do {
            smallTaskList = try context.fetch(SmallTask.fetchRequest())
            DispatchQueue.main.async {
                self.smallTaskTableView.reloadData()
            }
        } catch {
            
        }
    }
    
    @IBAction func addSmallTaskAction(_ sender: Any) {
        performSegue(withIdentifier: "toAddSmallTaskSegue", sender: self)
    }
    
    @IBAction func addNewTaskAction(_ sender: Any) {
        if taskTitleField.text?.isEmpty == true {
            Helper.showAlert(title: "Task Name Required", message: "You need to give the task a name", over: self)
        }
        else if smallTaskList.count == 0 {
            Helper.showAlert(title: "Minimum 1 Small Task Required", message: "You need to add minimum 1 small task to be able to create a task", over: self)
        }
        else {
            let newTask = Task(context: context)
            
            newTask.title = taskTitleField.text!
            newTask.dueDate = dueDatePicker.date
            newTask.progress = 50
            
            for smallTask in smallTaskList {
                newTask.addToSmallTasks(smallTask)
            }
            do {
                try self.context.save()
            } catch {
                
            }
            isViewing = false
            selectedSmallTaskIndex = -1
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddSmallTaskSegue" {
            let dest = segue.destination as! AddViewSmallTaskViewController
            
            dest.smallTaskList = smallTaskList
            if selectedSmallTaskIndex != -1 {
                dest.selectedSmallTask = smallTaskList[selectedSmallTaskIndex]
                dest.isViewing = true
                dest.selectedSmallTaskIndex = selectedSmallTaskIndex
            }
        }
    }
}

extension AddViewTaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        smallTaskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "smallTaskCell", for: indexPath) as! TodaysTaskCell
        
        let task = smallTaskList[indexPath.section]

        cell.taskTitleLabel.text = task.title
        cell.priorityLabel.text = task.priority
        cell.priorityLabel.backgroundColor = setTagColor(value: task.priority!)
        cell.difficultyLabel.text = task.difficulty
        cell.difficultyLabel.backgroundColor = setTagColor(value: task.difficulty!)
        if task.setTime == true {
            cell.taskTimeLabel.text = Helper.getTimeString(hour: task.hour!, minute: task.minute!)
        }
        else {
            cell.taskTimeLabel.text = "-"
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSmallTaskIndex = indexPath.section
        performSegue(withIdentifier: "toAddSmallTaskSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let removedTask = self.smallTaskList[indexPath.section]
            if self.isViewing == true {
                self.context.delete(removedTask)
                do {
                    try self.context.save()
                }
                catch {
                    
                }
            }
            self.smallTaskList.remove(at: indexPath.section)
            self.smallTaskTableView.reloadData()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var action = UIContextualAction()
        if smallTaskList[indexPath.section].isDone == false {
            action = UIContextualAction(style: .normal, title: "Finish") { (action, view, completionHandler) in
                let finishedSmallTask = self.smallTaskList[indexPath.section]
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
                let finishedSmallTask = self.smallTaskList[indexPath.section]
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
