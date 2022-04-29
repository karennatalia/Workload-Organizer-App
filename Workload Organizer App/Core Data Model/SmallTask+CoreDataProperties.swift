//
//  SmallTask+CoreDataProperties.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 29/04/22.
//
//

import Foundation
import CoreData


extension SmallTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SmallTask> {
        return NSFetchRequest<SmallTask>(entityName: "SmallTask")
    }

    @NSManaged public var assignToday: Bool
    @NSManaged public var dateToDo: Date?
    @NSManaged public var difficulty: String?
    @NSManaged public var hour: String?
    @NSManaged public var minute: String?
    @NSManaged public var priority: String?
    @NSManaged public var setDate: Bool
    @NSManaged public var setTime: Bool
    @NSManaged public var title: String?
    @NSManaged public var isDone: Bool
    @NSManaged public var task: Task?

}

extension SmallTask : Identifiable {

}
