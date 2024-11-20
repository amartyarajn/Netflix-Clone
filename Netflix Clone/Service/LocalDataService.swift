//
//  CoreDataManager.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 07/05/23.
//

import Foundation
import UIKit
import CoreData

class LocalDataService {
    
    static let shared = LocalDataService()
    
    func get<T:NSManagedObject>(for entity: T.Type, predicate: NSPredicate?, fetchLimit: Int?) -> [T] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let request = T.fetchRequest()
        request.predicate = predicate
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        var objects = [T]()
        context.performAndWait {
            do {
                objects = try context.fetch(request) as! [T]
            } catch {
                print(error.localizedDescription)
            }
        }
        return objects
        
    }
    
    func delete<T:NSManagedObject>(entity: T.Type, predicate: NSPredicate?) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let request = T.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        
        var isDeleted = false
        context.performAndWait {
            do {
                let records = try context.fetch(request) as! [T]
                if records.count > 0 {
                    context.delete(records[0])
                    try context.save()
                    isDeleted = true
                } else {
                    isDeleted = false
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return isDeleted
    }
    
    func saveTitle(for title: TitleMOProtocol, accountId: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        context.performAndWait {
            let titleItem = TitleItem(context: context)
            
            titleItem.id64 = Int64(title.id ?? 0)
            titleItem.overview = title.overview
            titleItem.posterPath = title.posterPath
            titleItem.name = title.name
            titleItem.mediaType = title.mediaType
            titleItem.accountId64 = Int64(accountId)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveUserDetails(accountId: Int?, username: String?, avatarPath: String?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        context.performAndWait {
            let userDetails = UserDetails(context: context)
            
            userDetails.accountId = Int64(accountId ?? 0)
            userDetails.username = username
            userDetails.avatarPath = avatarPath
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
