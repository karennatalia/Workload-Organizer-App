//
//  Task+CoreDataProperties.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 29/04/22.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var progress: Int16
    @NSManaged public var title: String?
    @NSManaged public var smallTasks: NSSet?

}

// MARK: Generated accessors for smallTasks
extension Task {

    @objc(addSmallTasksObject:)
    @NSManaged public func addToSmallTasks(_ value: SmallTask)

    @objc(removeSmallTasksObject:)
    @NSManaged public func removeFromSmallTasks(_ value: SmallTask)

    @objc(addSmallTasks:)
    @NSManaged public func addToSmallTasks(_ values: NSSet)

    @objc(removeSmallTasks:)
    @NSManaged public func removeFromSmallTasks(_ values: NSSet)

}

extension Task : Identifiable {

}
