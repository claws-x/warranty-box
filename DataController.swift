//
//  DataController.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import Foundation
import CoreData

/// CoreData 数据控制器
class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WarrantyBox")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("CoreData 加载失败：\(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// 保存上下文
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("保存失败：\(error.localizedDescription)")
            }
        }
    }
    
    /// 创建新的保修项目
    func createWarrantyItem(productName: String,
                           category: String,
                           purchaseDate: Date,
                           warrantyMonths: Int,
                           storeName: String? = nil,
                           notes: String? = nil,
                           imageData: Data? = nil) -> WarrantyItem {
        let item = WarrantyItem(context: container.viewContext)
        item.id = UUID()
        item.productName = productName
        item.category = category
        item.purchaseDate = purchaseDate
        item.warrantyMonths = Int32(warrantyMonths)
        item.storeName = storeName
        item.notes = notes
        item.imageData = imageData
        item.createdAt = Date()
        item.reminderEnabled = true
        
        save()
        return item
    }
    
    /// 获取所有保修项目（按到期时间排序）
    func fetchWarrantyItems() -> [WarrantyItem] {
        let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "purchaseDate", ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("获取数据失败：\(error.localizedDescription)")
            return []
        }
    }
    
    /// 删除保修项目
    func deleteWarrantyItem(_ item: WarrantyItem) {
        container.viewContext.delete(item)
        save()
    }
    
    /// 搜索保修项目
    func searchWarrantyItems(query: String) -> [WarrantyItem] {
        let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest()
        request.predicate = NSPredicate(format: "productName CONTAINS[cd] %@ OR storeName CONTAINS[cd] %@", query, query)
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("搜索失败：\(error.localizedDescription)")
            return []
        }
    }
    
    /// 按类别筛选
    func filterByCategory(_ category: String) -> [WarrantyItem] {
        let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("筛选失败：\(error.localizedDescription)")
            return []
        }
    }
}
