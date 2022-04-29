//
//  AddViewSmallTaskViewController.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

class AddViewSmallTaskViewController: UIViewController {
    
    @IBOutlet weak var titlePage: UILabel!
    @IBOutlet weak var smallTaskTitleField: UITextField!
    @IBOutlet weak var prioritySC: UISegmentedControl!
    @IBOutlet weak var difficultySC: UISegmentedControl!
    @IBOutlet weak var dateToDoPicker: UIDatePicker!
    @IBOutlet weak var setDateSwitch: UISwitch!
    @IBOutlet weak var setTimeSwitch: UISwitch!
    @IBOutlet weak var additionalBGView: UIView!
    @IBOutlet weak var timeNeededPicker: UIDatePicker!
    @IBOutlet weak var leftActionBtn: UIButton!
    @IBOutlet weak var rightActionBtn: UIButton!
    
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewHeightConstraint: NSLayoutConstraint!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var smallTaskList: [SmallTask] = []
    var selectedSmallTask: SmallTask?
    var selectedSmallTaskIndex = -1
    var isViewing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        closeDatePicker()
        closeTimePicker()
        titlePage.text = "Add Small Task"
        
        if isViewing == true {
            titlePage.text = "Small Task"
            smallTaskTitleField.text = selectedSmallTask?.title
            prioritySC.selectedSegmentIndex = getPriorityIndex()
            difficultySC.selectedSegmentIndex = getDifficultyIndex()
            if selectedSmallTask?.setDate == true {
                setDateSwitch.isOn = true
                dateToDoPicker.date = (selectedSmallTask?.dateToDo)!
                openDatePicker()
            }
            if selectedSmallTask?.setTime == true {
                setTimeSwitch.isOn = true
                
                let timeString = (selectedSmallTask?.hour)! + ":" + (selectedSmallTask?.minute)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                timeNeededPicker.date = dateFormatter.date(from: timeString)!
                openTimePicker()
            }
            leftActionBtn.setTitle("Save Change", for: .normal)
            if selectedSmallTask?.assignToday == false {
                rightActionBtn.setTitle("Do This Today", for: .normal)
            }
            else {
                rightActionBtn.setTitle("Not Today", for: .normal)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isViewing = false
    }
    
    @IBAction func setDateSwitchChanged(_ sender: Any) {
        if setDateSwitch.isOn {
            openDatePicker()
        }
        else {
            closeDatePicker()
        }
    }
    
    @IBAction func setTimeSwitchChanged(_ sender: Any) {
        if setTimeSwitch.isOn {
            openTimePicker()
        }
        else {
            closeTimePicker()
        }
    }
    
    @IBAction func cancelOrSaveAction(_ sender: Any) {
        if isViewing == true {
            let updatedSmallTask = smallTaskList[selectedSmallTaskIndex]
//            let newSmallTask = SmallTask(context: context)
            updatedSmallTask.title = smallTaskTitleField.text!
            updatedSmallTask.priority = getPriority()
            updatedSmallTask.difficulty = getDifficulty()

            if setDateSwitch.isOn {
                updatedSmallTask.setDate = true
                updatedSmallTask.dateToDo = dateToDoPicker.date
            }
            else {
                updatedSmallTask.setDate = false
                updatedSmallTask.dateToDo = nil
            }

            if setTimeSwitch.isOn {
                updatedSmallTask.setTime = true

                let dateComp = Calendar.current.dateComponents([.hour, .minute], from: timeNeededPicker.date)
                updatedSmallTask.hour = "\(dateComp.hour!)"
                updatedSmallTask.minute = "\(dateComp.minute!)"
            }
            else {
                updatedSmallTask.setTime = false
                updatedSmallTask.hour = ""
                updatedSmallTask.minute = ""
            }

            updatedSmallTask.assignToday = false
            smallTaskList[selectedSmallTaskIndex] = updatedSmallTask
        }
        performSegue(withIdentifier: "unwindToAddViewTask", sender: self)
    }
    
    @IBAction func addSmallTaskAction(_ sender: Any) {
        if isViewing == true {
            // add to today
            if selectedSmallTask?.assignToday == false {
                selectedSmallTask?.assignToday = true
                rightActionBtn.setTitle("Not Today", for: .normal)
            }
            else {
                selectedSmallTask?.assignToday = false
                rightActionBtn.setTitle("Do This Today", for: .normal)
            }
            do {
                try self.context.save()
            } catch {

            }
        }
        else {
            if smallTaskTitleField.text?.isEmpty == true {
                Helper.showAlert(title: "Small Task Name Required", message: "You need to give the small task a name", over: self)
            }
            else {
                let newSmallTask = SmallTask(context: context)
                newSmallTask.title = smallTaskTitleField.text!
                newSmallTask.priority = getPriority()
                newSmallTask.difficulty = getDifficulty()

                if setDateSwitch.isOn {
                    newSmallTask.setDate = true
                    newSmallTask.dateToDo = dateToDoPicker.date
                }
                else {
                    newSmallTask.setDate = false
                    newSmallTask.dateToDo = nil
                }

                if setTimeSwitch.isOn {
                    newSmallTask.setTime = true

                    let dateComp = Calendar.current.dateComponents([.hour, .minute], from: timeNeededPicker.date)
                    newSmallTask.hour = "\(dateComp.hour!)"
                    newSmallTask.minute = "\(dateComp.minute!)"
                }
                else {
                    newSmallTask.setTime = false
                    newSmallTask.hour = ""
                    newSmallTask.minute = ""
                }

                newSmallTask.assignToday = false
                newSmallTask.isDone = false
                smallTaskList.append(newSmallTask)
                
                isViewing = false
                performSegue(withIdentifier: "unwindToAddViewTask", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToAddViewTask" {
            let dest = segue.destination as! AddViewTaskViewController
            dest.smallTaskList = smallTaskList
        }
    }
    
    func openDatePicker() {
        dateToDoPicker.isHidden = false
        datePickerHeightConstraint.constant = 105
        bgViewHeightConstraint.constant += 105
    }
    
    func closeDatePicker() {
        dateToDoPicker.isHidden = true
        datePickerHeightConstraint.constant = 0
        bgViewHeightConstraint.constant -= 105
    }
    
    func openTimePicker() {
        timeNeededPicker.isHidden = false
        timePickerHeightConstraint.constant = 105
        bgViewHeightConstraint.constant += 105
    }
    
    func closeTimePicker() {
        timeNeededPicker.isHidden = true
        timePickerHeightConstraint.constant = 0
        bgViewHeightConstraint.constant -= 105
    }
    
    func getPriorityIndex() -> Int {
        switch selectedSmallTask?.priority {
        case "Low Priority":
            return 0
        case "Medium Priority":
            return 1
        case "High Priority":
            return 2
        default:
            return 0
        }
    }
    
    func getDifficultyIndex() -> Int {
        switch selectedSmallTask?.difficulty {
        case "Easy":
            return 0
        case "Medium":
            return 1
        case "Hard":
            return 2
        default:
            return 0
        }
    }
    
    func getPriority() -> String {
        switch prioritySC.selectedSegmentIndex {
        case 0:
            return "Low Priority"
        case 1:
            return "Medium Priority"
        case 2:
            return "High Priority"
        default:
            return "No Priority"
        }
    }
    
    func getDifficulty() -> String {
        switch difficultySC.selectedSegmentIndex {
        case 0:
            return "Easy"
        case 1:
            return "Medium"
        case 2:
            return "Hard"
        default:
            return "None"
        }
    }
    
}
