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
    @IBOutlet weak var setTimeSwitch: UISwitch!
    @IBOutlet weak var additionalBGView: UIView!
    @IBOutlet weak var timeNeededPicker: UIDatePicker!
    @IBOutlet weak var rightActionBtn: UIButton!
    
    @IBOutlet weak var timePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewHeightConstraint: NSLayoutConstraint!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var smallTaskList: [SmallTask] = []
    var selectedSmallTask: SmallTask?
    var selectedSmallTaskIndex = -1
    var isViewing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("view did load small task :: \(selectedSmallTaskIndex)")
        
        closeTimePicker()
        titlePage.text = "Add Small Task"
        setButtonStyle(titleText: "Add Small Task", colorName: "Red")
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction(sender:)))
        
        if isViewing == true {
            titlePage.text = "Small Task"
            smallTaskTitleField.text = selectedSmallTask?.title
            prioritySC.selectedSegmentIndex = getPriorityIndex()
            difficultySC.selectedSegmentIndex = getDifficultyIndex()
            if selectedSmallTask?.setTime == true {
                setTimeSwitch.isOn = true
                
                let timeString = (selectedSmallTask?.hour)! + ":" + (selectedSmallTask?.minute)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                timeNeededPicker.date = dateFormatter.date(from: timeString)!
                openTimePicker()
            }
            if selectedSmallTask?.assignToday == false {
                setButtonStyle(titleText: "Do This Today", colorName: "Red")
            }
            else {
                setButtonStyle(titleText: "Remove From Today's Task", colorName: "LightRed")
            }
        }
    }
    
    func setButtonStyle(titleText: String, colorName: String) {
        rightActionBtn.layer.cornerRadius = 5.0
        rightActionBtn.setTitleColor(UIColor.white, for: .normal)
        rightActionBtn.backgroundColor = UIColor(named: colorName)
        rightActionBtn.setTitle(titleText, for: .normal)
        if colorName == "Red" {
            rightActionBtn.setTitleColor(UIColor.white, for: .normal)
        }
        else {
            rightActionBtn.setTitleColor(UIColor(named: "Red"), for: .normal)
        }
    }
    
    @objc func backAction(sender: UIBarButtonItem) {
        print("back clicked")
        if isViewing == true {  // save
            if smallTaskTitleField.text?.isEmpty == true {
                Helper.showAlert(title: "Small Task Name Required", message: "You need to give the small task a name", over: self)
            }
            else {
                print(selectedSmallTaskIndex)
                let updatedSmallTask = smallTaskList[selectedSmallTaskIndex]
                updatedSmallTask.title = smallTaskTitleField.text!
                updatedSmallTask.priority = getPriority()
                updatedSmallTask.difficulty = getDifficulty()

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

                smallTaskList[selectedSmallTaskIndex] = updatedSmallTask
                
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func addSmallTaskAction(_ sender: Any) {
        if isViewing == true {
            // add to today
            if selectedSmallTask?.assignToday == false {
                selectedSmallTask?.assignToday = true
                setButtonStyle(titleText: "Remove From Today's Task", colorName: "LightRed")
            }
            else {
                selectedSmallTask?.assignToday = false
                setButtonStyle(titleText: "Do This Today", colorName: "Red")
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
                self.navigationController?.popViewController(animated: true)
            }
        }
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
