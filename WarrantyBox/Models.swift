//
//  Models.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import Foundation
import CoreData
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case chinese = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chinese:
            return "简体中文"
        case .english:
            return "English"
        }
    }
}

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "selected_app_language")
        }
    }

    private init() {
        let storedLanguage = UserDefaults.standard.string(forKey: "selected_app_language")
        language = AppLanguage(rawValue: storedLanguage ?? "") ?? .chinese
    }

    private var translations: [String: [AppLanguage: String]] {
        [
            "common.cancel": [.chinese: "取消", .english: "Cancel"],
            "common.save": [.chinese: "保存", .english: "Save"],
            "common.update": [.chinese: "更新", .english: "Update"],
            "common.confirm": [.chinese: "确定", .english: "OK"],
            "common.notice": [.chinese: "提示", .english: "Notice"],
            "add.title": [.chinese: "添加保修项目", .english: "Add Warranty Item"],
            "add.editTitle": [.chinese: "编辑保修项目", .english: "Edit Warranty Item"],
            "add.receipt": [.chinese: "添加凭证", .english: "Add Receipt"],
            "add.receiptHint": [.chinese: "拍照或从相册选择", .english: "Take a photo or choose from library"],
            "add.removeImage": [.chinese: "移除图片", .english: "Remove Image"],
            "add.basicInfo": [.chinese: "基本信息", .english: "Basic Info"],
            "add.productName": [.chinese: "商品名称", .english: "Product Name"],
            "add.category": [.chinese: "类别", .english: "Category"],
            "add.purchaseDate": [.chinese: "购买日期", .english: "Purchase Date"],
            "add.warrantyMonths": [.chinese: "保修期限：%d 个月", .english: "Warranty: %d months"],
            "add.preview": [.chinese: "保修预览", .english: "Warranty Preview"],
            "add.expirationDate": [.chinese: "预计到期日", .english: "Expected Expiration"],
            "add.remainingTime": [.chinese: "剩余时间", .english: "Time Remaining"],
            "add.storeInfo": [.chinese: "商家信息", .english: "Store Info"],
            "add.storeName": [.chinese: "商家名称（可选）", .english: "Store Name (Optional)"],
            "add.notes": [.chinese: "备注（可选）", .english: "Notes (Optional)"],
            "add.reminderSettings": [.chinese: "提醒设置", .english: "Reminder Settings"],
            "add.enableReminder": [.chinese: "启用到期提醒", .english: "Enable Expiration Reminder"],
            "add.reminderHint": [.chinese: "将在保修到期前 30 天、7 天、1 天发送通知", .english: "Notifications are sent 30, 7, and 1 day before expiration"],
            "add.chooseImage": [.chinese: "选择图片", .english: "Choose Image"],
            "add.camera": [.chinese: "拍照", .english: "Camera"],
            "add.photoLibrary": [.chinese: "从相册选择", .english: "Photo Library"],
            "add.enterProductName": [.chinese: "请输入商品名称", .english: "Please enter a product name"],
            "add.saveFailed": [.chinese: "保存失败：", .english: "Save failed: "],
            "add.notificationPermissionDisabled": [.chinese: "通知权限未开启，无法启用到期提醒。你可以先关闭提醒，或前往设置中开启通知权限。", .english: "Notifications are disabled. Turn off reminders first or enable notification permission in Settings."],
            "add.cannotReadImage": [.chinese: "无法读取所选图片", .english: "Unable to read the selected image"],
            "add.readImageFailed": [.chinese: "读取图片失败：", .english: "Failed to load image: "],
            "add.cameraUnavailable": [.chinese: "当前环境不支持相机。请在真机上测试拍照功能，并确认已授予相机权限。", .english: "Camera is unavailable in the current environment. Test this on a real device and confirm camera permission is granted."],
            "home.title": [.chinese: "保修管家", .english: "WarrantyBox"],
            "home.empty": [.chinese: "还没有保修项目", .english: "No Warranty Items Yet"],
            "home.emptyHint": [.chinese: "点击右上角加号，录入你的第一条保修记录。", .english: "Tap the plus button to add your first warranty item."],
            "home.noMatch": [.chinese: "没有匹配结果", .english: "No Results"],
            "home.noMatchHint": [.chinese: "换个关键词，或调整上方分类筛选。", .english: "Try another keyword or adjust the filters above."],
            "home.search": [.chinese: "搜索商品或商家", .english: "Search products or stores"],
            "home.sort": [.chinese: "排序", .english: "Sort"],
            "home.totalItems": [.chinese: "总项目", .english: "Total"],
            "home.expiredItems": [.chinese: "已过期", .english: "Expired"],
            "home.dueSoonItems": [.chinese: "7天内到期", .english: "Due in 7 Days"],
            "home.remindersOn": [.chinese: "提醒开启", .english: "Reminders On"],
            "home.unknownStore": [.chinese: "未知商家", .english: "Unknown Store"],
            "home.expirationLabel": [.chinese: "到期：%@", .english: "Expires: %@"],
            "detail.status": [.chinese: "状态", .english: "Status"],
            "detail.currentStatus": [.chinese: "当前状态", .english: "Current Status"],
            "detail.expirationDate": [.chinese: "到期日期", .english: "Expiration Date"],
            "detail.remainingTime": [.chinese: "剩余时间", .english: "Time Remaining"],
            "detail.basicInfo": [.chinese: "基本信息", .english: "Basic Info"],
            "detail.productName": [.chinese: "商品名称", .english: "Product Name"],
            "detail.category": [.chinese: "商品类别", .english: "Category"],
            "detail.purchaseDate": [.chinese: "购买日期", .english: "Purchase Date"],
            "detail.warrantyMonths": [.chinese: "保修期限", .english: "Warranty Term"],
            "detail.monthsValue": [.chinese: "%d 个月", .english: "%d months"],
            "detail.storeInfo": [.chinese: "商家信息", .english: "Store Info"],
            "detail.storeName": [.chinese: "商家名称", .english: "Store Name"],
            "detail.notes": [.chinese: "备注", .english: "Notes"],
            "detail.reminder": [.chinese: "提醒", .english: "Reminder"],
            "detail.reminderStatus": [.chinese: "到期提醒", .english: "Expiration Reminder"],
            "detail.disableReminder": [.chinese: "关闭提醒", .english: "Turn Off Reminder"],
            "detail.enableReminder": [.chinese: "开启提醒", .english: "Turn On Reminder"],
            "detail.receiptImage": [.chinese: "凭证图片", .english: "Receipt Image"],
            "detail.edit": [.chinese: "编辑", .english: "Edit"],
            "detail.delete": [.chinese: "删除", .english: "Delete"],
            "detail.deleteConfirmTitle": [.chinese: "删除这个保修项目？", .english: "Delete this warranty item?"],
            "detail.deleteConfirmMessage": [.chinese: "删除后无法恢复，相关提醒也会一并移除。", .english: "This action can't be undone. Related reminders will also be removed."],
            "settings.title": [.chinese: "设置", .english: "Settings"],
            "settings.done": [.chinese: "完成", .english: "Done"],
            "settings.language": [.chinese: "语言", .english: "Language"],
            "settings.notifications": [.chinese: "通知", .english: "Notifications"],
            "settings.currentStatus": [.chinese: "当前状态", .english: "Current Status"],
            "settings.requestPermission": [.chinese: "请求通知权限", .english: "Request Notification Permission"],
            "settings.refreshReminders": [.chinese: "重新同步提醒", .english: "Refresh Reminders"],
            "settings.openSystemSettings": [.chinese: "打开系统设置", .english: "Open System Settings"],
            "settings.privacy": [.chinese: "隐私说明", .english: "Privacy"],
            "settings.privacyLine1": [.chinese: "WarrantyBox 仅在本机保存你的保修项目、备注和凭证图片，不会自动上传到远程服务器。", .english: "WarrantyBox stores your warranty items, notes, and receipt images locally on your device and doesn't automatically upload them to a remote server."],
            "settings.privacyLine2": [.chinese: "如果你启用了到期提醒，应用会使用系统通知在保修临近到期时提醒你。", .english: "If reminders are enabled, the app uses local notifications to alert you before warranty expiration."],
            "settings.privacyLine3": [.chinese: "如果后续开启拍照或相册权限，相关访问仅用于选择凭证图片。", .english: "If you grant camera or photo library access, it is only used to attach receipt images."],
            "settings.about": [.chinese: "关于应用", .english: "About"],
            "settings.appName": [.chinese: "应用名称", .english: "App Name"],
            "settings.coreFeatures": [.chinese: "核心能力", .english: "Core Features"],
            "settings.featuresValue": [.chinese: "保修记录、到期提醒、凭证管理", .english: "Warranty records, expiration reminders, receipt management"],
            "settings.version": [.chinese: "版本", .english: "Version"],
            "settings.releaseCheck": [.chinese: "上架检查", .english: "Release Checklist"],
            "settings.notDetermined": [.chinese: "未决定", .english: "Not Determined"],
            "settings.denied": [.chinese: "已拒绝", .english: "Denied"],
            "settings.authorized": [.chinese: "已允许", .english: "Authorized"],
            "settings.provisional": [.chinese: "临时允许", .english: "Provisional"],
            "settings.ephemeral": [.chinese: "临时会话", .english: "Ephemeral"],
            "settings.unknown": [.chinese: "未知", .english: "Unknown"],
            "release.notifications": [.chinese: "通知权限说明", .english: "Notification Permission"],
            "release.notificationsReady": [.chinese: "通知权限可用，提醒功能可正常工作。", .english: "Notification permission is available and reminders can work normally."],
            "release.notificationsPending": [.chinese: "请在真机上确认通知权限申请与系统设置跳转。", .english: "Verify notification permission and Settings redirection on a real device."],
            "release.camera": [.chinese: "相机权限文案", .english: "Camera Permission Copy"],
            "release.cameraReady": [.chinese: "已检测到相机用途说明。", .english: "Camera usage description is present."],
            "release.cameraMissing": [.chinese: "缺少 `NSCameraUsageDescription`，拍照入口上架前必须补齐。", .english: "Missing `NSCameraUsageDescription`; camera usage text must be added before release."],
            "release.photos": [.chinese: "相册权限文案", .english: "Photo Library Permission Copy"],
            "release.photosReady": [.chinese: "已检测到相册用途说明。", .english: "Photo library usage description is present."],
            "release.photosMissing": [.chinese: "缺少 `NSPhotoLibraryUsageDescription`，相册选图上架前必须补齐。", .english: "Missing `NSPhotoLibraryUsageDescription`; photo library usage text must be added before release."],
            "release.tests": [.chinese: "测试 Target", .english: "Test Target"],
            "release.testsDetail": [.chinese: "当前工程已包含基础测试，请继续补充 UI 与提醒相关测试。", .english: "The project now includes basic tests. Continue adding UI and reminder coverage."],
            "release.assets": [.chinese: "App Icon 与商店素材", .english: "App Icon & Store Assets"],
            "release.assetsDetail": [.chinese: "请在 Xcode 资源目录和 App Store Connect 中手动确认图标、截图和隐私政策链接。", .english: "Manually verify icons, screenshots, and privacy policy links in Xcode and App Store Connect."],
            "reminder.disable": [.chinese: "关闭提醒", .english: "Turn Off Reminder"],
            "reminder.enable": [.chinese: "开启提醒", .english: "Turn On Reminder"],
            "notification.title.expiring": [.chinese: "保修即将到期", .english: "Warranty Expiring Soon"],
            "notification.body.30days": [.chinese: "“%@” 的保修将在 30 天后到期", .english: "\"%@\" warranty expires in 30 days"],
            "notification.body.7days": [.chinese: "“%@” 的保修将在 7 天后到期，请及时处理", .english: "\"%@\" warranty expires in 7 days. Please take action soon"],
            "notification.title.tomorrow": [.chinese: "保修明天到期", .english: "Warranty Expires Tomorrow"],
            "notification.body.1day": [.chinese: "“%@” 的保修将在明天到期", .english: "\"%@\" warranty expires tomorrow"],
            "status.expired": [.chinese: "已过期", .english: "Expired"],
            "status.expiringSoon": [.chinese: "即将过期", .english: "Expiring Soon"],
            "status.remainingDays": [.chinese: "剩余 %d 天", .english: "%d days left"],
            "status.normal": [.chinese: "正常", .english: "Active"],
            "status.expiresToday": [.chinese: "今天到期", .english: "Expires today"],
            "status.checkWarrantyMonths": [.chinese: "请检查保修期限", .english: "Check warranty term"],
            "status.expiredDaysAgo": [.chinese: "已过期 %d 天", .english: "Expired %d days ago"],
            "status.enabled": [.chinese: "已启用", .english: "Enabled"],
            "status.disabled": [.chinese: "未启用", .english: "Disabled"],
            "category.electronics": [.chinese: "电子产品", .english: "Electronics"],
            "category.appliances": [.chinese: "家用电器", .english: "Appliances"],
            "category.furniture": [.chinese: "家具", .english: "Furniture"],
            "category.clothing": [.chinese: "服装", .english: "Clothing"],
            "category.other": [.chinese: "其他", .english: "Other"],
            "sort.expiration": [.chinese: "按到期时间", .english: "By Expiration"],
            "sort.purchaseDate": [.chinese: "按购买时间", .english: "By Purchase Date"],
            "sort.name": [.chinese: "按名称", .english: "By Name"],
            "filter.all": [.chinese: "全部", .english: "All"],
            "filter.expiringSoon": [.chinese: "30天内到期", .english: "Due in 30 Days"],
            "filter.expired": [.chinese: "已过期", .english: "Expired"],
            "filter.reminders": [.chinese: "提醒已开", .english: "Reminders On"]
        ]
    }

    func text(_ key: String) -> String {
        translations[key]?[language] ?? key
    }

    func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: Locale(identifier: language.rawValue), arguments: arguments)
    }
}

/// 保修项目数据模型
@objc(WarrantyItem)
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
        let localization = LocalizationManager.shared
        if isExpired {
            return localization.text("status.expired")
        } else if daysRemaining <= 7 {
            return localization.text("status.expiringSoon")
        } else if daysRemaining <= 30 {
            return localization.format("status.remainingDays", daysRemaining)
        } else {
            return localization.text("status.normal")
        }
    }

    var urgencyRank: Int {
        if isExpired {
            return 0
        } else if daysRemaining <= 7 {
            return 1
        } else if daysRemaining <= 30 {
            return 2
        } else {
            return 3
        }
    }

    var remainingDescription: String {
        let localization = LocalizationManager.shared
        if daysRemaining < 0 {
            return localization.format("status.expiredDaysAgo", -daysRemaining)
        } else if daysRemaining == 0 {
            return localization.text("status.expiresToday")
        } else {
            return localization.format("status.remainingDays", daysRemaining)
        }
    }

    var statusColor: Color {
        if isExpired {
            return .red
        } else if daysRemaining <= 7 {
            return .orange
        } else if daysRemaining <= 30 {
            return .yellow
        } else {
            return .green
        }
    }
}

extension WarrantyItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<WarrantyItem> {
        NSFetchRequest<WarrantyItem>(entityName: "WarrantyItem")
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

    var localizationKey: String {
        switch self {
        case .electronics: return "category.electronics"
        case .appliances: return "category.appliances"
        case .furniture: return "category.furniture"
        case .clothing: return "category.clothing"
        case .other: return "category.other"
        }
    }

    var localizedName: String {
        LocalizationManager.shared.text(localizationKey)
    }

    func localizedName(using localization: LocalizationManager) -> String {
        localization.text(localizationKey)
    }
    
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
