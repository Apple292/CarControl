//
//  AppSettings+CoreDataProperties.swift
//  Pajero
//
//  Created by Aiden Wood on 9/4/2025.
//
//

import Foundation
import CoreData


extension AppSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSettings> {
        return NSFetchRequest<AppSettings>(entityName: "AppSettings")
    }

    @NSManaged public var showltestat: Bool
    @NSManaged public var showcamera: Bool

}

extension AppSettings : Identifiable {

}
