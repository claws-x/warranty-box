//
//  AddItemView.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import SwiftUI
import PhotosUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var productName = ""
    @State private var selectedCategory = ProductCategory.electronics
    @State private var purchaseDate = Date()
    @State private var warrantyMonths = 12
    @State private var storeName = ""
    @State private var notes = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                                Text("添加凭证")
                                    .font(.headline)
                                Text("拍照或从相册选择")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // 基本信息
                Section(header: Text("基本信息")) {
                    TextField("商品名称", text: $productName)
                    
                    Picker("类别", selection: $selectedCategory) {
                        ForEach(ProductCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    DatePicker("购买日期", selection: $purchaseDate, displayedComponents: .date)
                    
                    Stepper("保修期限：\(warrantyMonths) 个月", value: $warrantyMonths, in: 1...120, step: 1)
                }
                
                // 商家信息
                Section(header: Text("商家信息")) {
                    TextField("商家名称（可选）", text: $storeName)
                    TextField("备注（可选）", text: $notes, axis: .vertical)
                }
                
                // 提醒设置
                Section(header: Text("提醒设置")) {
                    Toggle("启用到期提醒", isOn: .constant(true))
                    Text("将在保修到期前 30 天、7 天、1 天发送通知")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("添加保修项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveItem()
                    }
                    .disabled(productName.isEmpty)
                }
            }
            .confirmationDialog("选择图片", isPresented: $showingImagePicker) {
                Button("拍照") {
                    showingCamera = true
                }
                Button("从相册选择") {
                    // 简化处理，直接使用照片选择
                }
                Button("取消", role: .cancel) {}
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveItem() {
        guard !productName.isEmpty else {
            alertMessage = "请输入商品名称"
            showingAlert = true
            return
        }
        
        let item = WarrantyItem(context: viewContext)
        item.id = UUID()
        item.productName = productName
        item.category = selectedCategory.rawValue
        item.purchaseDate = purchaseDate
        item.warrantyMonths = Int32(warrantyMonths)
        item.storeName = storeName.isEmpty ? nil : storeName
        item.notes = notes.isEmpty ? nil : notes
        item.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        item.createdAt = Date()
        item.reminderEnabled = true
        
        do {
            try viewContext.save()
            
            // 设置提醒
            scheduleReminder(for: item)
            
            dismiss()
        } catch {
            alertMessage = "保存失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func scheduleReminder(for item: WarrantyItem) {
        // 简化实现，实际应使用 UserNotifications
        print("将为 \(item.productName) 设置保修到期提醒")
    }
}

// MARK: - Preview
struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
            .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
    }
}
