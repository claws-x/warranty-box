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
        container = NSPersistentContainer(name: "WarrantyBox", managedObjectModel: Self.makeManagedObjectModel())
        
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

    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "WarrantyItem"
        entity.managedObjectClassName = NSStringFromClass(WarrantyItem.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let productName = NSAttributeDescription()
        productName.name = "productName"
        productName.attributeType = .stringAttributeType
        productName.isOptional = false

        let category = NSAttributeDescription()
        category.name = "category"
        category.attributeType = .stringAttributeType
        category.isOptional = false

        let purchaseDate = NSAttributeDescription()
        purchaseDate.name = "purchaseDate"
        purchaseDate.attributeType = .dateAttributeType
        purchaseDate.isOptional = false

        let warrantyMonths = NSAttributeDescription()
        warrantyMonths.name = "warrantyMonths"
        warrantyMonths.attributeType = .integer32AttributeType
        warrantyMonths.isOptional = false
        warrantyMonths.defaultValue = 12

        let storeName = NSAttributeDescription()
        storeName.name = "storeName"
        storeName.attributeType = .stringAttributeType
        storeName.isOptional = true

        let notes = NSAttributeDescription()
        notes.name = "notes"
        notes.attributeType = .stringAttributeType
        notes.isOptional = true

        let imageData = NSAttributeDescription()
        imageData.name = "imageData"
        imageData.attributeType = .binaryDataAttributeType
        imageData.isOptional = true
        imageData.allowsExternalBinaryDataStorage = true

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let reminderEnabled = NSAttributeDescription()
        reminderEnabled.name = "reminderEnabled"
        reminderEnabled.attributeType = .booleanAttributeType
        reminderEnabled.isOptional = false
        reminderEnabled.defaultValue = true

        entity.properties = [
            id,
            productName,
            category,
            purchaseDate,
            warrantyMonths,
            storeName,
            notes,
            imageData,
            createdAt,
            reminderEnabled
        ]

        model.entities = [entity]
        return model
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
        let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest() as! NSFetchRequest<WarrantyItem>
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

    /// 获取已启用提醒的保修项目
    func fetchReminderEnabledItems() -> [WarrantyItem] {
        let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest()
        request.predicate = NSPredicate(format: "reminderEnabled == YES")

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("获取提醒项目失败：\(error.localizedDescription)")
            return []
        }
    }
    
    /// 搜索保修项目
    func searchWarrantyItems(query: String) -> [WarrantyItem] {
        let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest() as! NSFetchRequest<WarrantyItem>
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
        let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest() as! NSFetchRequest<WarrantyItem>
        request.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("筛选失败：\(error.localizedDescription)")
            return []
        }
    }
}
