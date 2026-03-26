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
    
    private init() {}
    
    /// 请求通知权限
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知权限请求失败：\(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }
    
    /// 为保修项目设置提醒
    func scheduleReminder(for item: WarrantyItem) {
        let expirationDate = item.expirationDate
        
        // 到期前 30 天提醒
        if let date30 = Calendar.current.date(byAdding: .day, value: -30, to: expirationDate) {
            scheduleNotification(
                for: item,
                date: date30,
                identifier: "\(item.id.uuidString)_30days",
                title: "保修即将到期",
                body: "「\(item.productName)」的保修将在 30 天后到期"
            )
        }
        
        // 到期前 7 天提醒
        if let date7 = Calendar.current.date(byAdding: .day, value: -7, to: expirationDate) {
            scheduleNotification(
                for: item,
                date: date7,
                identifier: "\(item.id.uuidString)_7days",
                title: "保修即将到期",
                body: "「\(item.productName)」的保修将在 7 天后到期，请及时处理"
            )
        }
        
        // 到期前 1 天提醒
        if let date1 = Calendar.current.date(byAdding: .day, value: -1, to: expirationDate) {
            scheduleNotification(
                for: item,
                date: date1,
                identifier: "\(item.id.uuidString)_1day",
                title: "保修明天到期",
                body: "「\(item.productName)」的保修将在明天到期"
            )
        }
    }
    
    /// 安排单个通知
    private func scheduleNotification(for item: WarrantyItem,
                                      date: Date,
                                      identifier: String,
                                      title: String,
                                      body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["warrantyItemId": item.id.uuidString]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
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
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// 取消所有提醒
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
