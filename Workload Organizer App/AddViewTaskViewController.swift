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
    @IBOutlet weak var leftActionBtn: UIButton!
//    var newTask = Task()
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
        smallTaskTableView.delegate = self
        smallTaskTableView.dataSource = self
        
        titlePage.text = "Add New Task"
        
//        newTask = Task(context: context)
        
        if isViewing == true {
            titlePage.text = "Task"
            taskTitleField.text = selectedTask?.title
            dueDatePicker.date = (selectedTask?.dueDate)!
            smallTaskList = selectedTask?.smallTasks?.allObjects as! [SmallTask]
            rightActionBtn.setTitle("Do All Today", for: .normal)
            leftActionBtn.setTitle("Save Change", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedSmallTaskIndex = -1
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if self.isMovingFromParent && isViewing == true {
//            print("ismoving")
//            if smallTaskList.count == 0 {
//                Helper.showAlert(title: "Minimum 1 Small Task Required", message: "You need to add minimum 1 small task to be able to create a task", over: self)
//            }
//        }
//    }

    func fetchSmallTasks() {
        do {
            smallTaskList = try context.fetch(SmallTask.fetchRequest())
            DispatchQueue.main.async {
                self.smallTaskTableView.reloadData()
            }
        } catch {
            
        }
    }
    
    @IBAction func cancelOrSaveAction(_ sender: Any) {
        if isViewing == true {
            delegate?.updateData(taskTitle: taskTitleField.text!, newDueDate: dueDatePicker.date, progress: 50, smallTaskList: smallTaskList, updatedIndex: selectedIndex)
        }
        performSegue(withIdentifier: "unwindToMyTasks", sender: self)
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
            performSegue(withIdentifier: "unwindToMyTasks", sender: self)
        }
    }
    
//    func setNewTaskData() {
//        newTask.title = taskTitleField.text!
//        newTask.dueDate = dueDatePicker.date
//        newTask.progress = 50
//
//        for smallTask in smallTaskList {
//            newTask.addToSmallTasks(smallTask)
//        }
//    }
    
    @IBAction func unwindToAddViewTask(_ unwindSegue: UIStoryboardSegue) {
        smallTaskTableView.reloadData()
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
        print(task)

        cell.taskTitleLabel.text = task.title
        cell.priorityLabel.text = task.priority
        cell.priorityLabel.backgroundColor = setTagColor(value: task.priority!)
        cell.difficultyLabel.text = task.difficulty
        cell.difficultyLabel.backgroundColor = setTagColor(value: task.difficulty!)
        cell.taskTimeLabel.text = getDateTimeText(task: task)
        
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
    
    func getDateTimeText(task: SmallTask) -> String {
        var dateTimeText = ""
        
        if task.setDate == true && task.setTime == true {
            dateTimeText += Helper.formatDate(date: task.dateToDo!)
            dateTimeText += " \(getTimeString(hour: task.hour!, minute: task.minute!))"
        }
        else if task.setDate == true {
            dateTimeText = Helper.formatDate(date: task.dateToDo!)
        }
        else if task.setTime == true {
            dateTimeText = "- \(getTimeString(hour: task.hour!, minute: task.minute!))"
        }
        else {
            dateTimeText = "-"
        }
        
        return dateTimeText
    }
    
    func getTimeString(hour: String, minute: String) -> String {
        var timeString = "( "
        
        if hour != "" && hour != "0" {
            timeString += "\(hour) hour "
        }
        if minute != "" && minute != "0" {
            timeString += "\(minute) minutes "
        }
        
        timeString += ")"
        return timeString
    }
    
}
