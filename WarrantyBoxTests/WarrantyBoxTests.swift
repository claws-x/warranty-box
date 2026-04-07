import Foundation
import Testing
@testable import WarrantyBox

struct WarrantyBoxTests {
    @Test
    func warrantyExpirationCalculatesFromPurchaseDate() {
        let controller = DataController(inMemory: true)
        let item = WarrantyItem(context: controller.container.viewContext)
        item.id = UUID()
        item.productName = "MacBook Pro"
        item.category = ProductCategory.electronics.rawValue
        item.purchaseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        item.warrantyMonths = 12
        item.createdAt = item.purchaseDate
        item.reminderEnabled = false

        let expectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 15))
        #expect(Calendar.current.isDate(item.expirationDate, inSameDayAs: expectedDate!))
    }

    @Test
    func expiredWarrantyReportsExpiredState() {
        let controller = DataController(inMemory: true)
        let item = WarrantyItem(context: controller.container.viewContext)
        item.id = UUID()
        item.productName = "AirPods"
        item.category = ProductCategory.electronics.rawValue
        item.purchaseDate = Calendar.current.date(byAdding: .month, value: -13, to: Date())!
        item.warrantyMonths = 12
        item.createdAt = item.purchaseDate
        item.reminderEnabled = true

        #expect(item.isExpired)
        #expect(item.statusText == "已过期")
        #expect(item.remainingDescription.contains("已过期"))
    }

    @Test
    func activeWarrantyProducesFutureRemainingDescription() {
        let controller = DataController(inMemory: true)
        let item = WarrantyItem(context: controller.container.viewContext)
        item.id = UUID()
        item.productName = "Dyson"
        item.category = ProductCategory.appliances.rawValue
        item.purchaseDate = Date()
        item.warrantyMonths = 24
        item.createdAt = Date()
        item.reminderEnabled = true

        #expect(!item.isExpired)
        #expect(item.daysRemaining >= 365)
        #expect(item.remainingDescription.contains("剩余"))
    }
}
