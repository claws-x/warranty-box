//
//  NotificationManager.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import Foundation
import UserNotifications

/// 通知管理器
class NotificationManager {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    /// 请求通知权限
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知权限请求失败：\(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }

    func fetchAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    func ensureAuthorization(completion: @escaping (Bool) -> Void) {
        fetchAuthorizationStatus { status in
            switch status {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .notDetermined:
                self.requestAuthorization(completion: completion)
            case .denied:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
    
    /// 为保修项目设置提醒
    func scheduleReminder(for item: WarrantyItem) {
        cancelReminders(for: item)

        guard item.reminderEnabled else { return }

        let expirationDate = item.expirationDate
        let localization = LocalizationManager.shared
        
        // 到期前 30 天提醒
        if let date30 = Calendar.current.date(byAdding: .day, value: -30, to: expirationDate) {
            scheduleNotification(
                for: item,
                date: date30,
                identifier: "\(item.id.uuidString)_30days",
                title: localization.text("notification.title.expiring"),
                body: localization.format("notification.body.30days", item.productName)
            )
        }
        
        // 到期前 7 天提醒
        if let date7 = Calendar.current.date(byAdding: .day, value: -7, to: expirationDate) {
            scheduleNotification(
                for: item,
                date: date7,
                identifier: "\(item.id.uuidString)_7days",
                title: localization.text("notification.title.expiring"),
                body: localization.format("notification.body.7days", item.productName)
            )
        }
        
        // 到期前 1 天提醒
        if let date1 = Calendar.current.date(byAdding: .day, value: -1, to: expirationDate) {
            scheduleNotification(
                for: item,
                date: date1,
                identifier: "\(item.id.uuidString)_1day",
                title: localization.text("notification.title.tomorrow"),
                body: localization.format("notification.body.1day", item.productName)
            )
        }
    }

    /// 启动时同步所有提醒，确保持久化数据与系统通知一致
    func refreshReminders(for items: [WarrantyItem]) {
        for item in items {
            if item.reminderEnabled {
                scheduleReminder(for: item)
            } else {
                cancelReminders(for: item)
            }
        }
    }
    
    /// 安排单个通知
    private func scheduleNotification(for item: WarrantyItem,
                                      date: Date,
                                      identifier: String,
                                      title: String,
                                      body: String) {
        guard date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["warrantyItemId": item.id.uuidString]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("添加通知失败：\(error.localizedDescription)")
            } else {
                print("已为 \(item.productName) 设置提醒：\(title)")
            }
        }
    }
    
    /// 取消某个项目的所有提醒
    func cancelReminders(for item: WarrantyItem) {
        let identifiers = [
            "\(item.id.uuidString)_30days",
            "\(item.id.uuidString)_7days",
            "\(item.id.uuidString)_1day"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// 取消所有提醒
    func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
