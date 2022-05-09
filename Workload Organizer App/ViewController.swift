//
//  ViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 27/04/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var motivationLabel: UILabel!
    @IBOutlet weak var todaysTableView: UITableView!
    
    var todaysTaskList: [SmallTask] = []
    var finishedCount = 0
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todaysTableView.delegate = self
        todaysTableView.dataSource = self
        
        setGreetingText()
        fetchSmallTasks()
        checkFinished()
        checkNewDay()
        setMotivationText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        fetchSmallTasks()
        checkFinished()
        setMotivationText()
        todaysTableView.reloadData()
    }
    
    func checkNewDay() {
        let checkSaved = userDefaults.bool(forKey: "savedDate")
        let currDate = Calendar.current.component(.day, from: Date())
        if checkSaved == false {
            userDefaults.set(currDate, forKey: "savedDate")
        }
        else {
            let savedDate = userDefaults.object(forKey: "savedDate") as! Int
            let message:String
            if savedDate != currDate {
                userDefaults.set(currDate, forKey: "savedDate")
                if finishedCount == todaysTaskList.count {
                    message = "Great Job! You finished all tasks yesterday!"
                }
                else {
                    message = "You have some unfinished task yesterday"
                }
                showResetAlert(message: message)
            }
        }
    }
    
    func showResetAlert(message: String) {
        let alert = UIAlertController(title: "It's a New Day!", message: "\(message)\n\nDo you want to reset Today's Task List?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { action in
            self.removeSmallTaskAssignToday()
            self.todaysTaskList.removeAll()
            self.finishedCount = 0
        })
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func removeSmallTaskAssignToday() {
        for task in todaysTaskList {
            task.assignToday = false
        }
        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.todaysTableView.reloadData()
            }
        } catch {

        }
    }
    
    func setGreetingText() {
        let hourNow = (Calendar.current.component(.hour, from: Date()))
        if hourNow >= 5 && hourNow < 12 {
            greetingLabel.text = "Good Morning"
        }
        else if hourNow >= 12 && hourNow < 17 {
            greetingLabel.text = "Good Afternoon"
        }
        else if hourNow >= 17 && hourNow < 21 {
            greetingLabel.text = "Good Evening"
        }
        else {
            greetingLabel.text = "Good Night"
        }
    }
    
    func setMotivationText() {
        if todaysTaskList.count == 0 {
            motivationLabel.text = "Add some task to do today!"
        }
        else {
            if finishedCount == todaysTaskList.count {
                motivationLabel.text = "Yay, you have finished all tasks!"
            }
            else {
                motivationLabel.text = "You only have \(todaysTaskList.count - finishedCount) tasks left today!"
            }
        }
    }
    
    func checkFinished() {
        finishedCount = 0
        for task in todaysTaskList {
            if task.isDone == true {
                finishedCount += 1
            }
        }
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
    
    func getSmallTaskList(selectedIndex: Int) -> [SmallTask] {
        do {
            let taskTitle = todaysTaskList[selectedIndex].task?.title
            let fetchTask: NSFetchRequest<Task> = Task.fetchRequest()
            fetchTask.predicate = NSPredicate(format: "title = %@", taskTitle!)

            let task = try! context.fetch(fetchTask)
            return task[0].smallTasks?.allObjects as! [SmallTask]
        } catch {
            print(error)
        }
    }
    
    func getSelectedTaskIndex(selectedIndex: Int) -> Int {
        let smallTasks = getSmallTaskList(selectedIndex: selectedIndex)
        for (index, smallTask) in smallTasks.enumerated() {
            if smallTask.title == todaysTaskList[selectedIndex].title {
                return index
            }
        }
        return 0
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let addViewTaskVC = storyboard.instantiateViewController(withIdentifier: "addViewTaskID") as? AddViewTaskViewController,
           let addViewSmallTaskVC = storyboard.instantiateViewController(withIdentifier: "addViewSmallTaskID") as? AddViewSmallTaskViewController {
            
            // setip add view task vc
            addViewTaskVC.isViewing = true
            addViewTaskVC.selectedTask = todaysTaskList[indexPath.section].task
            
            // setup add view small task vc
            addViewSmallTaskVC.selectedSmallTask = todaysTaskList[indexPath.section]
            addViewSmallTaskVC.smallTaskList = getSmallTaskList(selectedIndex: indexPath.section)
            addViewSmallTaskVC.selectedSmallTaskIndex = getSelectedTaskIndex(selectedIndex: indexPath.section)
            addViewSmallTaskVC.isViewing = true
            
            let VCStack = [self, addViewTaskVC, addViewSmallTaskVC]
            self.navigationController?.setViewControllers(VCStack, animated: true)
        }
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
            self.checkFinished()
            self.setMotivationText()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var action = UIContextualAction()
        if todaysTaskList[indexPath.section].isDone == false {
            action = UIContextualAction(style: .normal, title: "Finish") { (action, view, completionHandler) in
                let finishedSmallTask = self.todaysTaskList[indexPath.section]
                finishedSmallTask.isDone = true
                self.finishedCount += 1
                self.setMotivationText()
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
                self.finishedCount -= 1
                self.setMotivationText()
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

