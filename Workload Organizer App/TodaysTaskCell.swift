//
//  TodaysTaskCell.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

class TodaysTaskCell: UITableViewCell {

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var checkMark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        priorityLabel.layer.cornerRadius = 5
        priorityLabel.layer.masksToBounds = true
        
        difficultyLabel.layer.cornerRadius = 5
        difficultyLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
