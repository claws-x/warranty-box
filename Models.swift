//
//  Models.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import Foundation
import CoreData

/// 保修项目数据模型
class WarrantyItem: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var productName: String
    @NSManaged var category: String
    @NSManaged var purchaseDate: Date
    @NSManaged var warrantyMonths: Int32
    @NSManaged var storeName: String?
    @NSManaged var notes: String?
    @NSManaged var imageData: Data?
    @NSManaged var createdAt: Date
    @NSManaged var reminderEnabled: Bool
    
    /// 计算保修到期日期
    var expirationDate: Date {
        Calendar.current.date(byAdding: .month, value: Int(warrantyMonths), to: purchaseDate) ?? purchaseDate
    }
    
    /// 是否已过期
    var isExpired: Bool {
        Date() > expirationDate
    }
    
    /// 剩余天数
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }
    
    /// 状态文本
    var statusText: String {
        if isExpired {
            return "已过期"
        } else if daysRemaining <= 7 {
            return "即将过期"
        } else if daysRemaining <= 30 {
            return "剩余 \(daysRemaining) 天"
        } else {
            return "正常"
        }
    }
}

/// 商品类别枚举
enum ProductCategory: String, CaseIterable, Identifiable {
    case electronics = "电子产品"
    case appliances = "家用电器"
    case furniture = "家具"
    case clothing = "服装"
    case other = "其他"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .electronics: return "iphone"
        case .appliances: return "washer"
        case .furniture: return "chair"
        case .clothing: return "tshirt"
        case .other: return "bag"
        }
    }
}
