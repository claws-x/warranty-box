//
//  ContentView.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import SwiftUI
import CoreData
import UIKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localization: LocalizationManager
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showingAddItem = false
    @State private var showingSettings = false
    @AppStorage("selected_sort_option") private var selectedSortOptionRawValue = SortOption.expiration.rawValue
    @State private var selectedQuickFilter: QuickFilter = .all
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WarrantyItem.purchaseDate, ascending: false)],
        animation: .default)
    private var items: FetchedResults<WarrantyItem>
    
    var filteredItems: [WarrantyItem] {
        var result = items.filter { item in
            if searchText.isEmpty {
                return true
            }
            return item.productName.localizedCaseInsensitiveContains(searchText) ||
                   (item.storeName?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        switch selectedQuickFilter {
        case .all:
            break
        case .expiringSoon:
            result = result.filter { !$0.isExpired && $0.daysRemaining <= 30 }
        case .expired:
            result = result.filter(\.isExpired)
        case .reminders:
            result = result.filter(\.reminderEnabled)
        }
        
        switch selectedSortOption {
        case .expiration:
            return result.sorted { lhs, rhs in
                if lhs.urgencyRank != rhs.urgencyRank {
                    return lhs.urgencyRank < rhs.urgencyRank
                }
                return lhs.expirationDate < rhs.expirationDate
            }
        case .purchaseDate:
            return result.sorted { $0.purchaseDate > $1.purchaseDate }
        case .name:
            return result.sorted { $0.productName.localizedCompare($1.productName) == .orderedAscending }
        }
    }

    private var summary: WarrantySummary {
        WarrantySummary(items: Array(items))
    }

    private var selectedSortOption: SortOption {
        get { SortOption(rawValue: selectedSortOptionRawValue) ?? .expiration }
        set { selectedSortOptionRawValue = newValue.rawValue }
    }

    private var sortOptionBinding: Binding<SortOption> {
        Binding(
            get: { SortOption(rawValue: selectedSortOptionRawValue) ?? .expiration },
            set: { selectedSortOptionRawValue = $0.rawValue }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SummaryHeaderView(summary: summary)
                QuickFilterBar(selectedQuickFilter: $selectedQuickFilter)

                // 类别筛选
                CategoryFilterView(selectedCategory: $selectedCategory)
                
                // 保修项目列表
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty && selectedCategory == nil ? t("home.empty") : t("home.noMatch"),
                        systemImage: searchText.isEmpty && selectedCategory == nil ? "shippingbox" : "magnifyingglass",
                        description: Text(searchText.isEmpty && selectedCategory == nil ? t("home.emptyHint") : t("home.noMatchHint"))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink {
                                WarrantyItemDetailView(item: item)
                            } label: {
                                WarrantyItemRow(item: item)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                reminderToggleButton(for: item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(t("home.title"))
            .searchable(text: $searchText, prompt: t("home.search"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker(t("home.sort"), selection: sortOptionBinding) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.localizedTitle(using: localization)).tag(option)
                            }
                        }
                    } label: {
                        Label(t("home.sort"), systemImage: "arrow.up.arrow.down.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                        }

                        Button(action: { showingAddItem = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredItems[$0] }

        for item in itemsToDelete {
            NotificationManager.shared.cancelReminders(for: item)
            viewContext.delete(item)
        }

        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }

    @ViewBuilder
    private func reminderToggleButton(for item: WarrantyItem) -> some View {
        Button {
            toggleReminder(for: item)
        } label: {
            Label(item.reminderEnabled ? localization.text("reminder.disable") : localization.text("reminder.enable"), systemImage: item.reminderEnabled ? "bell.slash" : "bell")
        }
        .tint(item.reminderEnabled ? .gray : .green)
    }

    private func toggleReminder(for item: WarrantyItem) {
        if item.reminderEnabled {
            item.reminderEnabled = false
            NotificationManager.shared.cancelReminders(for: item)

            do {
                try viewContext.save()
            } catch {
                viewContext.rollback()
            }
            return
        }

        NotificationManager.shared.ensureAuthorization { granted in
            DispatchQueue.main.async {
                guard granted else { return }
                item.reminderEnabled = true

                do {
                    try viewContext.save()
                    NotificationManager.shared.scheduleReminder(for: item)
                } catch {
                    viewContext.rollback()
                }
            }
        }
    }

    private func t(_ key: String) -> String {
        localization.text(key)
    }
}

struct SummaryHeaderView: View {
    @EnvironmentObject private var localization: LocalizationManager
    let summary: WarrantySummary

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                SummaryCardView(title: localization.text("home.totalItems"), value: "\(summary.totalCount)", tint: .blue, systemImage: "shippingbox")
                SummaryCardView(title: localization.text("home.expiredItems"), value: "\(summary.expiredCount)", tint: .red, systemImage: "exclamationmark.triangle")
                SummaryCardView(title: localization.text("home.dueSoonItems"), value: "\(summary.dueSoonCount)", tint: .orange, systemImage: "clock.badge.exclamationmark")
                SummaryCardView(title: localization.text("home.remindersOn"), value: "\(summary.reminderEnabledCount)", tint: .green, systemImage: "bell.badge")
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
}

struct SummaryCardView: View {
    let title: String
    let value: String
    let tint: Color
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundColor(tint)

            Text(value)
                .font(.title2.weight(.bold))

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 132, alignment: .leading)
        .padding()
        .background(tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct QuickFilterBar: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Binding var selectedQuickFilter: QuickFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(QuickFilter.allCases) { filter in
                    FilterChip(title: filter.localizedTitle(using: localization), isSelected: selectedQuickFilter == filter) {
                        selectedQuickFilter = filter
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
}

/// 类别筛选视图
struct CategoryFilterView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Binding var selectedCategory: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: localization.text("filter.all"), isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                ForEach(ProductCategory.allCases) { category in
                    FilterChip(title: category.localizedName(using: localization), isSelected: selectedCategory == category.rawValue) {
                        selectedCategory = category.rawValue
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6))
    }
}

/// 筛选按钮
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

/// 保修项目行视图
struct WarrantyItemRow: View {
    @EnvironmentObject private var localization: LocalizationManager
    let item: WarrantyItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 商品图片
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                Image(systemName: item.categoryIcon)
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(.headline)
                
                Text(item.storeName ?? localization.text("home.unknownStore"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text(item.statusText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(item.statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Text(localization.format("home.expirationLabel", item.expirationDate.formatted(date: .abbreviated, time: .omitted)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct WarrantyItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localization: LocalizationManager

    @ObservedObject var item: WarrantyItem

    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section(localization.text("detail.status")) {
                LabeledContent(localization.text("detail.currentStatus"), value: item.statusText)
                LabeledContent(localization.text("detail.expirationDate"), value: item.expirationDate.formatted(date: .abbreviated, time: .omitted))
                LabeledContent(localization.text("detail.remainingTime"), value: item.remainingDescription)
            }

            Section(localization.text("detail.basicInfo")) {
                LabeledContent(localization.text("detail.productName"), value: item.productName)
                LabeledContent(localization.text("detail.category"), value: ProductCategory.allCases.first(where: { $0.rawValue == item.category })?.localizedName(using: localization) ?? item.category)
                LabeledContent(localization.text("detail.purchaseDate"), value: item.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                LabeledContent(localization.text("detail.warrantyMonths"), value: localization.format("detail.monthsValue", Int(item.warrantyMonths)))
            }

            if let storeName = item.storeName, !storeName.isEmpty {
                Section(localization.text("detail.storeInfo")) {
                    LabeledContent(localization.text("detail.storeName"), value: storeName)
                }
            }

            if let notes = item.notes, !notes.isEmpty {
                Section(localization.text("detail.notes")) {
                    Text(notes)
                }
            }

            Section(localization.text("detail.reminder")) {
                LabeledContent(localization.text("detail.reminderStatus"), value: item.reminderEnabled ? localization.text("status.enabled") : localization.text("status.disabled"))
                Button(item.reminderEnabled ? localization.text("detail.disableReminder") : localization.text("detail.enableReminder")) {
                    toggleReminder()
                }
            }

            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Section(localization.text("detail.receiptImage")) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }
        }
        .navigationTitle(item.productName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(localization.text("detail.edit")) {
                    showingEditSheet = true
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button(localization.text("detail.delete"), role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddItemView(item: item)
        }
        .confirmationDialog(localization.text("detail.deleteConfirmTitle"), isPresented: $showingDeleteConfirmation) {
            Button(localization.text("detail.delete"), role: .destructive) {
                deleteItem()
            }
            Button(localization.text("common.cancel"), role: .cancel) {}
        } message: {
            Text(localization.text("detail.deleteConfirmMessage"))
        }
    }

    private func deleteItem() {
        NotificationManager.shared.cancelReminders(for: item)
        viewContext.delete(item)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            viewContext.rollback()
        }
    }

    private func toggleReminder() {
        if item.reminderEnabled {
            item.reminderEnabled = false
            NotificationManager.shared.cancelReminders(for: item)

            do {
                try viewContext.save()
            } catch {
                viewContext.rollback()
            }
            return
        }

        NotificationManager.shared.ensureAuthorization { granted in
            DispatchQueue.main.async {
                guard granted else { return }
                item.reminderEnabled = true

                do {
                    try viewContext.save()
                    NotificationManager.shared.scheduleReminder(for: item)
                } catch {
                    viewContext.rollback()
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localization: LocalizationManager

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationStack {
            List {
                Section(localization.text("settings.language")) {
                    Picker(localization.text("settings.language"), selection: $localization.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }

                Section(localization.text("settings.notifications")) {
                    LabeledContent(localization.text("settings.currentStatus"), value: notificationStatusText)

                    Button(localization.text("settings.requestPermission")) {
                        NotificationManager.shared.requestAuthorization { _ in
                            loadNotificationStatus()
                        }
                    }

                    Button(localization.text("settings.refreshReminders")) {
                        refreshReminders()
                    }

                    Button(localization.text("settings.openSystemSettings")) {
                        openSystemSettings()
                    }
                }

                Section(localization.text("settings.privacy")) {
                    Text(localization.text("settings.privacyLine1"))
                    Text(localization.text("settings.privacyLine2"))
                    Text(localization.text("settings.privacyLine3"))
                }

                Section(localization.text("settings.about")) {
                    LabeledContent(localization.text("settings.appName"), value: "WarrantyBox")
                    LabeledContent(localization.text("settings.coreFeatures"), value: localization.text("settings.featuresValue"))
                    LabeledContent(localization.text("settings.version"), value: appVersionText)
                }

                Section(localization.text("settings.releaseCheck")) {
                    ForEach(releaseChecklistItems) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: item.isReady ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(item.isReady ? .green : .orange)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                Text(item.detail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(localization.text("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localization.text("settings.done")) {
                        dismiss()
                    }
                }
            }
            .task {
                loadNotificationStatus()
            }
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .notDetermined:
            return localization.text("settings.notDetermined")
        case .denied:
            return localization.text("settings.denied")
        case .authorized:
            return localization.text("settings.authorized")
        case .provisional:
            return localization.text("settings.provisional")
        case .ephemeral:
            return localization.text("settings.ephemeral")
        @unknown default:
            return localization.text("settings.unknown")
        }
    }

    private func loadNotificationStatus() {
        NotificationManager.shared.fetchAuthorizationStatus { status in
            DispatchQueue.main.async {
                notificationStatus = status
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url)
    }

    private func refreshReminders() {
        NotificationManager.shared.fetchAuthorizationStatus { status in
            guard status == .authorized || status == .provisional || status == .ephemeral else { return }

            let request: NSFetchRequest<WarrantyItem> = WarrantyItem.fetchRequest()

            do {
                let items = try viewContext.fetch(request)
                NotificationManager.shared.refreshReminders(for: items)
            } catch {
                print("重新同步提醒失败：\(error.localizedDescription)")
            }
        }
    }

    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var releaseChecklistItems: [ReleaseChecklistItem] {
        [
            ReleaseChecklistItem(
                title: localization.text("release.notifications"),
                detail: notificationStatus == .authorized || notificationStatus == .provisional || notificationStatus == .ephemeral ? localization.text("release.notificationsReady") : localization.text("release.notificationsPending")
            ),
            ReleaseChecklistItem(
                title: localization.text("release.camera"),
                detail: Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil ? localization.text("release.cameraReady") : localization.text("release.cameraMissing"),
                isReady: Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil
            ),
            ReleaseChecklistItem(
                title: localization.text("release.photos"),
                detail: Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") != nil ? localization.text("release.photosReady") : localization.text("release.photosMissing"),
                isReady: Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") != nil
            ),
            ReleaseChecklistItem(
                title: localization.text("release.tests"),
                detail: localization.text("release.testsDetail")
            ),
            ReleaseChecklistItem(
                title: localization.text("release.assets"),
                detail: localization.text("release.assetsDetail"),
                isReady: false
            )
        ]
    }
}

struct WarrantySummary {
    let totalCount: Int
    let expiredCount: Int
    let dueSoonCount: Int
    let reminderEnabledCount: Int

    init(items: [WarrantyItem]) {
        totalCount = items.count
        expiredCount = items.filter(\.isExpired).count
        dueSoonCount = items.filter { !$0.isExpired && $0.daysRemaining <= 7 }.count
        reminderEnabledCount = items.filter(\.reminderEnabled).count
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case expiration
    case purchaseDate
    case name

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expiration:
            return LocalizationManager.shared.text("sort.expiration")
        case .purchaseDate:
            return LocalizationManager.shared.text("sort.purchaseDate")
        case .name:
            return LocalizationManager.shared.text("sort.name")
        }
    }

    func localizedTitle(using localization: LocalizationManager) -> String {
        switch self {
        case .expiration:
            return localization.text("sort.expiration")
        case .purchaseDate:
            return localization.text("sort.purchaseDate")
        case .name:
            return localization.text("sort.name")
        }
    }
}

enum QuickFilter: String, CaseIterable, Identifiable {
    case all
    case expiringSoon
    case expired
    case reminders

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return LocalizationManager.shared.text("filter.all")
        case .expiringSoon:
            return LocalizationManager.shared.text("filter.expiringSoon")
        case .expired:
            return LocalizationManager.shared.text("filter.expired")
        case .reminders:
            return LocalizationManager.shared.text("filter.reminders")
        }
    }

    func localizedTitle(using localization: LocalizationManager) -> String {
        switch self {
        case .all:
            return localization.text("filter.all")
        case .expiringSoon:
            return localization.text("filter.expiringSoon")
        case .expired:
            return localization.text("filter.expired")
        case .reminders:
            return localization.text("filter.reminders")
        }
    }
}

struct ReleaseChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    var isReady = true
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
            .environmentObject(LocalizationManager.shared)
    }
}

extension WarrantyItem {
    var categoryIcon: String {
        ProductCategory.allCases.first { $0.rawValue == category }?.icon ?? "bag"
    }
}
