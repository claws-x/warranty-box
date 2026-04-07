//
//  AddItemView.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localization: LocalizationManager
    
    private let existingItem: WarrantyItem?
    @State private var productName = ""
    @State private var selectedCategory = ProductCategory.electronics
    @State private var purchaseDate = Date()
    @State private var warrantyMonths = 12
    @State private var storeName = ""
    @State private var notes = ""
    @State private var reminderEnabled = true
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    @State private var isSaving = false
    
    @State private var showingAlert = false
    @State private var alertMessage = ""

    init(item: WarrantyItem? = nil) {
        existingItem = item
        _productName = State(initialValue: item?.productName ?? "")
        _selectedCategory = State(initialValue: ProductCategory.allCases.first(where: { $0.rawValue == item?.category }) ?? .electronics)
        _purchaseDate = State(initialValue: item?.purchaseDate ?? Date())
        _warrantyMonths = State(initialValue: item.map { Int($0.warrantyMonths) } ?? 12)
        _storeName = State(initialValue: item?.storeName ?? "")
        _notes = State(initialValue: item?.notes ?? "")
        _reminderEnabled = State(initialValue: item?.reminderEnabled ?? true)
        _selectedImage = State(initialValue: item.flatMap { dataItem in
            dataItem.imageData.flatMap(UIImage.init(data:))
        })
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 商品图片
                Section {
                    Button(action: { showingImagePicker = true }) {
                        HStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .frame(width: 80, height: 80)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(t("add.receipt"))
                                    .font(.headline)
                                Text(t("add.receiptHint"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if selectedImage != nil {
                        Button(t("add.removeImage"), role: .destructive) {
                            selectedImage = nil
                        }
                    }
                }
                
                // 基本信息
                Section(header: Text(t("add.basicInfo"))) {
                    TextField(t("add.productName"), text: $productName)
                    
                    Picker(t("add.category"), selection: $selectedCategory) {
                        ForEach(ProductCategory.allCases) { category in
                            Text(category.localizedName).tag(category)
                        }
                    }
                    
                    DatePicker(t("add.purchaseDate"), selection: $purchaseDate, displayedComponents: .date)
                    
                    Stepper(f("add.warrantyMonths", warrantyMonths), value: $warrantyMonths, in: 1...120, step: 1)
                }

                Section(header: Text(t("add.preview"))) {
                    LabeledContent(t("add.expirationDate"), value: expirationDate.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent(t("add.remainingTime"), value: remainingDescription)
                }
                
                // 商家信息
                Section(header: Text(t("add.storeInfo"))) {
                    TextField(t("add.storeName"), text: $storeName)
                    TextField(t("add.notes"), text: $notes, axis: .vertical)
                }
                
                // 提醒设置
                Section(header: Text(t("add.reminderSettings"))) {
                    Toggle(t("add.enableReminder"), isOn: $reminderEnabled)
                    Text(t("add.reminderHint"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(existingItem == nil ? t("add.title") : t("add.editTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(t("common.cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(existingItem == nil ? t("common.save") : t("common.update")) {
                        saveItem()
                    }
                    .disabled(productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .disabled(isSaving)
                }
            }
            .confirmationDialog(t("add.chooseImage"), isPresented: $showingImagePicker) {
                Button(t("add.camera")) {
                    presentCameraIfAvailable()
                }
                Button(t("add.photoLibrary")) {
                    showingPhotoPicker = true
                }
                Button(t("common.cancel"), role: .cancel) {}
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                    .ignoresSafeArea()
            }
            .alert(t("common.notice"), isPresented: $showingAlert) {
                Button(t("common.confirm"), role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .task(id: selectedPhotoItem) {
                await loadSelectedPhoto()
            }
        }
    }
    
    private func saveItem() {
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStoreName = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            alertMessage = t("add.enterProductName")
            showingAlert = true
            return
        }

        guard !isSaving else { return }
        isSaving = true

        let persistChanges = {
            let item = existingItem ?? WarrantyItem(context: viewContext)
            if existingItem == nil {
                item.id = UUID()
                item.createdAt = Date()
            }
            item.productName = trimmedName
            item.category = selectedCategory.rawValue
            item.purchaseDate = purchaseDate
            item.warrantyMonths = Int32(warrantyMonths)
            item.storeName = trimmedStoreName.isEmpty ? nil : trimmedStoreName
            item.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            item.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
            item.reminderEnabled = reminderEnabled

            do {
                try viewContext.save()

                if reminderEnabled {
                    NotificationManager.shared.scheduleReminder(for: item)
                } else {
                    NotificationManager.shared.cancelReminders(for: item)
                }

                isSaving = false
                dismiss()
            } catch {
                isSaving = false
                alertMessage = "\(t("add.saveFailed"))\(error.localizedDescription)"
                showingAlert = true
            }
        }

        if reminderEnabled {
            NotificationManager.shared.ensureAuthorization { granted in
                DispatchQueue.main.async {
                    if granted {
                        persistChanges()
                    } else {
                        isSaving = false
                        alertMessage = t("add.notificationPermissionDisabled")
                        showingAlert = true
                    }
                }
            }
        } else {
            persistChanges()
        }
    }

    @MainActor
    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else { return }

        do {
            guard let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                alertMessage = t("add.cannotReadImage")
                showingAlert = true
                return
            }

            selectedImage = image
        } catch {
            alertMessage = "\(t("add.readImageFailed"))\(error.localizedDescription)"
            showingAlert = true
        }
    }

    private var canUseCamera: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera) &&
        Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil
    }

    private func presentCameraIfAvailable() {
        guard canUseCamera else {
            alertMessage = t("add.cameraUnavailable")
            showingAlert = true
            return
        }

        showingCamera = true
    }

    private var expirationDate: Date {
        Calendar.current.date(byAdding: .month, value: warrantyMonths, to: purchaseDate) ?? purchaseDate
    }

    private var remainingDescription: String {
        let months = Int32(warrantyMonths)
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0

        if days < 0 {
            return f("status.expiredDaysAgo", -days)
        } else if days == 0 {
            return t("status.expiresToday")
        } else if months <= 0 {
            return t("status.checkWarrantyMonths")
        } else {
            return f("status.remainingDays", days)
        }
    }

    private func t(_ key: String) -> String {
        localization.text(key)
    }

    private func f(_ key: String, _ value: Int) -> String {
        localization.format(key, value)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImage: $selectedImage, dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding private var selectedImage: UIImage?
        private let dismiss: DismissAction

        init(selectedImage: Binding<UIImage?>, dismiss: DismissAction) {
            _selectedImage = selectedImage
            self.dismiss = dismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            selectedImage = info[.originalImage] as? UIImage
            dismiss()
        }
    }
}

// MARK: - Preview
struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
            .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
            .environmentObject(LocalizationManager.shared)
    }
}
